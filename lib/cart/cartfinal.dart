import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';

import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/carrito.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:http/http.dart' as http;

class CartFinal extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  CartFinal({this.petModel, this.defaultChoiceIndex});

  @override
  _CartFinalState createState() => _CartFinalState();
}

class _CartFinalState extends State<CartFinal> {
  int count;
  dynamic sumaTotal = 0;
  List _cartResults = [];
  bool _value2 = false;
  PetModel model;
  bool _value = false;
  dynamic totalPet = 0;
  List<int> totalList = [];
  dynamic sum = 0;
  dynamic totalsum = 0;
  dynamic ppvalor = 0;
  int ppAcumulados = 0;
  int ppCanjeados = 0;
  bool procesando = false;
  final db = FirebaseFirestore.instance;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  BuildContext dialogContext;
  dynamic delivery = 0;
  String tituloCategoria = "Producto";
  bool carrito = true;
  bool noti = false;
  bool home = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Ciudades")
        .doc("Perú")
        .collection("Petpoints")
        .doc("Precio");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        ppvalor = (dataSnapshot.data()["petpointPE"]);
      });
      print('Valor PetPoint: $ppvalor');
    });

    _getPetpoints();
  }

  _getPetpoints() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    documentReference.get().then((dataSnapshot) {
      setState(() {
        ppAcumulados = (dataSnapshot.data()["ppAcumulados"]);
        ppCanjeados = (dataSnapshot.data()["ppCanjeados"]);
      });
      print('Valor Acumulado: $ppAcumulados');
      print('Valor canjeados: $ppCanjeados');
    });
  }

  Future borrarItem(aliadoId, precio, iTd) async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId);
    documentReference.get().then((dataSnapshot) {
      setState(() {
        sumaTotal = (dataSnapshot.data()["sumaTotal"]);
      });

      borrarTotal(aliadoId, precio, iTd);
    });
    return sumaTotal;
  }

  borrarTotal(aliadoId, precio, iTd) async {
    var data = await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .get();
    setState(() {
      count = data.docs.length;
    });
    if (count == 1) {
      await FirebaseFirestore.instance
          .collection("Dueños")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(aliadoId)
          .delete();
    }
    await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .doc(iTd)
        .delete();
    var likeRef2 = await db
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId);
    likeRef2.update({
      'sumaTotal': sumaTotal - precio,
    });
    setState(() {});
  }

  getAliadoSnapshots(aliadoId) async {
    var data = await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .get();
    setState(() {
      _cartResults = data.docs;
    });
    addAllItemsToOrder(_cartResults);

    return data.docs;
  }

  Future<List<ItemModel>> getAllSnapshots(aliadoId) async {
    var data = await db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .doc(aliadoId)
        .collection('Items')
        .get();

    var documentos = data.docs;
    List<ItemModel> listaItems = [];
    documentos.forEach((doc) {
      ItemModel item = ItemModel.fromJson(doc.data());
      listaItems.add(item);
    });

    return listaItems;
  }

  Widget sourceInfo(BuildContext context, ItemModel item) {
    // final cart = CarritoModel.fromSnapshot(document);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            producto(item, context),
          ],
        ),
      ),
    );
  }

  Widget producto(ItemModel cart, BuildContext context) {
    if (cart.productoId != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          decoration: BoxDecoration(
              color: Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              )),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              StreamBuilder(
                  stream: db
                      .collection('Productos')
                      .doc(cart.productoId)
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
                          ProductModel product =
                              ProductModel.fromJson(dataSnapshot.data.data());

                          dynamic precio = product.precio * cart.cantidad;

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 70.0,
                                      child: Image.network(
                                        product.urlImagen,
                                      )),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product.titulo,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left),
                                        Text(
                                          product.dirigido,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          product.presentacion != null
                                              ? product.presentacion
                                              : '',
                                          style: TextStyle(
                                            color: Color(0xFF57419D),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "A pagar ",
                                    style: TextStyle(
                                      color: Color(0xFF57419D),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Text(
                                    PetshopApp.sharedPreferences
                                        .getString(PetshopApp.simboloMoneda),
                                    style: TextStyle(
                                      color: Color(0xFF57419D),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    precio.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Color(0xFF57419D),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Cantidad: ',
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cart.cantidad.toString(),
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 100.0,
                    child: RaisedButton(
                      onPressed: () {
                        borrarItem(cart.aliadoId, cart.precio, cart.iId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartFinal()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Colors.red,
                      padding: EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Eliminar",
                              style: TextStyle(
                                fontFamily: 'Product Sans',
                                color: Colors.white,
                                fontSize: 16.0,
                              )),
                          Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      );
    }
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
            CustomBottomNavigationBar(home: home, cart: carrito, noti: noti),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StoreHome()),
                          );
                          // Navigator.pop(context);
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Text(
                        "Mis pedidos",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("Dueños")
                        .doc(PetshopApp.sharedPreferences
                            .getString(PetshopApp.userUID))
                        .collection('Cart')
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dataSnapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            CartModel cart = CartModel.fromJson(
                                dataSnapshot.data.docs[index].data());
                            //
                            // var listItems = getAllSnapshots(ali.aliadoId) as List;
                            return Column(
                              children: [
                                Text(
                                  cart.nombreComercial,
                                  style: TextStyle(
                                    color: Color(0xFF57419D),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FutureBuilder<List<ItemModel>>(
                                    future: getAllSnapshots(cart.aliadoId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState !=
                                          ConnectionState.done) {
                                        // return: show loading widget
                                      }
                                      if (snapshot.hasError) {
                                        // return: show error widget
                                      }
                                      List<ItemModel> listItems =
                                          snapshot.data ?? [];

                                      listItems.forEach((item) {
                                        var precio = item.precio;
                                        var cantidad = item.cantidad;
                                        totalsum += precio * cantidad;

                                        print(totalsum);
                                      });
                                      return Container(
                                        // height: _screenHeight,
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: listItems.length,
                                            itemBuilder: (context, index) {
                                              ItemModel item = listItems[index];

                                              return sourceInfo(
                                                  context, listItems[index]);
                                            }),
                                      );
                                    }),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sub total',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Color(0xFF57419D),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            PetshopApp.sharedPreferences
                                                .getString(
                                                    PetshopApp.simboloMoneda),
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            cart.sumaTotal.toStringAsFixed(2),
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Pet Points',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 70.0,
                                            child: RaisedButton(
                                              onPressed: () {},
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              color: Color(0xFFBBD7D6),
                                              padding: EdgeInsets.all(0.0),
                                              child: Text(
                                                  (ppAcumulados - ppCanjeados)
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Color(0xFF57419D),
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(13.0),
                                        child: Text(
                                          '=',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(0xFF57419D),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90.0,
                                        child: RaisedButton(
                                          onPressed: () {},
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          color: Color(0xFFBBD7D6),
                                          padding: EdgeInsets.all(0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  PetshopApp.sharedPreferences
                                                      .getString(PetshopApp
                                                          .simboloMoneda),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Color(0xFF57419D),
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  (ppvalor *
                                                          (ppAcumulados -
                                                              ppCanjeados))
                                                      .toStringAsPrecision(3),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Color(0xFF57419D),
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            3, 14, 0, 14),
                                        child: Text(
                                          '¿Aplicar?',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Color(0xFF57419D),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Checkbox(
                                          value: _value,
                                          activeColor: Color(0xFF57419D),
                                          onChanged: (bool value) {
                                            setState(() {
                                              _value = value;
                                              if (value) {
                                                totalPet = ppvalor *
                                                    (ppAcumulados -
                                                        ppCanjeados);
                                                setState(() {
                                                  _value = true;
                                                });
                                              } else {
                                                _value = false;
                                                totalPet = 0;
                                              }
                                            });
                                          }),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Descuento por PetPoints',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),

                                      // Text(
                                      //   PetshopApp.sharedPreferences
                                      //       .getString(
                                      //           PetshopApp.simboloMoneda),
                                      //   style: TextStyle(
                                      //       fontSize: 16.0,
                                      //       color: Colors.red,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      Text(
                                        '${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)} ${(totalPet).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder(
                                    stream: db
                                        .collection('Aliados')
                                        .doc(cart.aliadoId)
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: 1,
                                          shrinkWrap: true,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            AliadoModel ali =
                                                AliadoModel.fromJson(
                                                    dataSnapshot.data.data());
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ali.delivery != 0
                                                      ? Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Monto delivery',
                                                                          style: TextStyle(
                                                                              fontSize: 16.0,
                                                                              color: Color(0xFF57419D),
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              80.0,
                                                                          child:
                                                                              RaisedButton(
                                                                            onPressed:
                                                                                () {},
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                                            color:
                                                                                Color(0xFF57419D),
                                                                            padding:
                                                                                EdgeInsets.all(0.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda), style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                                Text((ali.delivery).toStringAsFixed(2), style: TextStyle(fontFamily: 'Product Sans', color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              10,
                                                                              0),
                                                                      child:
                                                                          Text(
                                                                        '¿Quieres delivery?',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16.0,
                                                                            color:
                                                                                Color(0xFF57419D),
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    Checkbox(
                                                                        value:
                                                                            _value2,
                                                                        activeColor:
                                                                            Color(
                                                                                0xFF57419D),
                                                                        onChanged:
                                                                            (bool
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            _value2 =
                                                                                value;
                                                                            if (value ==
                                                                                true) {
                                                                              delivery = ali.delivery;
                                                                            } else {
                                                                              delivery = 0;
                                                                            }
                                                                          });
                                                                        }),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            delivery != 0
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Cargo por Delivery',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xFF57419D),
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 18),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          // Text('Costo: ', style: TextStyle(color: Color(0xFF57419D), fontSize: 18, fontWeight: FontWeight.bold,),),
                                                                          Text(
                                                                            PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF57419D),
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            ali.delivery.toStringAsFixed(2),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF57419D),
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )
                                                      : Container(
                                                          height: 5,
                                                        ),
                                                ],
                                              ),
                                            );
                                          });
                                    }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total a cancelar',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Color(0xFF57419D),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            PetshopApp.sharedPreferences
                                                .getString(
                                                    PetshopApp.simboloMoneda),
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            (cart.sumaTotal -
                                                    totalPet +
                                                    delivery)
                                                .toStringAsFixed(2),
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0xFF57419D),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PetshopApp.pasarelaDisponible()
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: RaisedButton(
                                            onPressed: () {
                                              // AddOrder(context, cart);
                                              getAliadoSnapshots(cart.aliadoId);
                                              int totalPrice = (cart.sumaTotal -
                                                      totalPet +
                                                      delivery)
                                                  .toInt();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentPage(
                                                          petModel:
                                                              widget.petModel,
                                                          cartModel: cart,
                                                          tituloCategoria:
                                                          'Producto',
                                                          totalPrice:
                                                              totalPrice,
                                                          delivery: delivery,
                                                          value2: _value2,
                                                          value: _value,
                                                          onSuccess: (pagoId, estadoPago, montoAprobado) {
                                                            _respuestaPago(
                                                              pagoId, 
                                                              estadoPago, 
                                                              montoAprobado, 
                                                              cart, 
                                                              totalPrice,
                                                              delivery,
                                                              _value,
                                                              _value2);
                                                          },
                                                        )),
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            color: Color(0xFFEB9448),
                                            padding: EdgeInsets.all(10.0),
                                            child: Text("Pagar",
                                                style: TextStyle(
                                                    fontFamily: 'Product Sans',
                                                    color: Colors.white,
                                                    fontSize: 18.0)),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // createOrder(Map<String, dynamic> orderData) {
  // Navigator.of(context).push(
  //   MaterialPageRoute(builder: (context){
  //     return OrderScreen(orderData: orderData);
  //   }),
  // );
  // }

  Future<void> _respuestaPago(
    String pagoId, 
    String estadoPago, 
    int montoAprobado, 
    CartModel cart,
    int totalPrice,
    int localDelivery,
    bool value,
    bool value2
  ) async{
    int petPoints = 0;

    String estadoOrden;
    if(estadoPago == PagoEnum.pagoAprobado) {
      estadoOrden = OrdenEnum.aprobada;
      petPoints = totalPrice;
    }
    else {
      estadoOrden = OrdenEnum.pendiente;
    }

    Navigator.of(context, rootNavigator: true).pop();
    //OrderMessage(context, outcomeMsg);
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    await databaseReference.set({
      "aliadoId": cart.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": totalPrice,
      "tipoOrden": 'Producto',
      "createdOn": DateTime.now(),
      "status": estadoOrden,
      "ppGeneradosD": totalPrice,
      "tieneDelivery": value2,
      "delivery": delivery,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": cart.nombreComercial,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
    });

    setState(() {
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(cart.aliadoId)
          .collection('Items')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
        ;
      });
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(cart.aliadoId)
          .delete();
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(petPoints),
      'ppCanjeados': value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });


  }

  AddOrder(BuildContext context, CartModel cart) async {
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    await databaseReference.set({
      "aliadoId": cart.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse((cart.sumaTotal - totalPet.toInt()).toString()),
      "tipoOrden": 'Producto',
      "createdOn": DateTime.now(),
      "status": 'Por Confirmar',
      "ppGeneradosD": int.parse((cart.sumaTotal - totalPet.toInt()).toString()),
      "tieneDelivery": _value2,
      "delivery": delivery,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": cart.nombreComercial,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
    });
    // then((value) => databaseReference.snapshots().listen(onData))

    setState(() {
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(cart.aliadoId)
          .collection('Items')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
        ;
      });
      db
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(cart.aliadoId)
          .delete();
    });
  }

  Future addAllItemsToOrder(_cartResults) async {
    _cartResults.forEach((allPasteService) async {
      //Pegar la copia del servicio a esta nueva localidad
      await db
          .collection('Ordenes')
          .doc(productId)
          .collection('Items')
          .doc(CarritoModel.fromSnapshot(allPasteService).productoId)
          .set({
        "aliadoId": CarritoModel.fromSnapshot(allPasteService).aliadoId,
        "iId": CarritoModel.fromSnapshot(allPasteService).iId,
        "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
        "precio": CarritoModel.fromSnapshot(allPasteService).precio,
        "cantidad": CarritoModel.fromSnapshot(allPasteService).cantidad,
        "productoId": CarritoModel.fromSnapshot(allPasteService).productoId,
        "titulo": CarritoModel.fromSnapshot(allPasteService).titulo,
        "nombreComercial":
            CarritoModel.fromSnapshot(allPasteService).nombreComercial,
      });
    });
  }

  // void onData(DocumentSnapshot event) async {
  //
  //
  //   print(event.data);
  //   if (event.data['preference_id'] != null) {
  //     // Navigator.pop(dialogContext);
  //     // Navigator.of(context, rootNavigator: true).pop();
  //     var result = await MercadoPagoMobileCheckout.startCheckout(
  //         "TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3",
  //         event.data['preference_id']);
  //
  //     print(result);
  //
  //     if (result.status == 'approved') {
  //       var likeRef = db
  //           .collection("Dueños")
  //           .doc(
  //               PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
  //           .collection("Petpoints")
  //           .doc(
  //               PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
  //       likeRef.updateData({
  //         'ppAcumulados':
  //             FieldValue.increment(int.parse(result.transactionAmount)),
  //         'ppCanjeados': _value == true
  //             ? FieldValue.increment(ppAcumulados)
  //             : FieldValue.increment(0),
  //       });
  //       // FirebaseFirestore.instance.collection('Ordenes').doc(productId).updateData(
  //       //     {'preference_id': FieldValue.delete()}).whenComplete(() {});
  //
  //       showDialog(
  //         context: context,
  //         child: AlertDialog(
  //           // title: Text('Su pago ha sido aprobado.'),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: <Widget>[
  //                 Container(
  //                   width: MediaQuery.of(context).size.width * 0.91,
  //                   decoration: BoxDecoration(
  //                       color: Color(0xFF57419D),
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                         color: Color(0xFFBDD7D6),
  //                       )),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       children: [
  //                         Text(
  //                           'Tu pago ha sido procesado con éxito.',
  //                           style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 12),
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Text(
  //                             'Pronto recibirás un correo con la confirmación de tu compra.. ',
  //                             style:
  //                                 TextStyle(color: Colors.white, fontSize: 12)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 // Container(
  //                 //   width: MediaQuery.of(context).size.width*0.91,
  //                 //   decoration: BoxDecoration(
  //                 //       color: Colors.white,
  //                 //       borderRadius: BorderRadius.circular(10),
  //                 //       border: Border.all(color: Color(0xFFBDD7D6),)),
  //                 //   child: Padding(
  //                 //     padding: const EdgeInsets.all(8.0),
  //                 //     child: Column(
  //                 //       crossAxisAlignment: CrossAxisAlignment.start,
  //                 //       children: [
  //                 //         Text('Items', style: TextStyle(color: Color(0xFF57419D), fontWeight: FontWeight.bold, fontSize: 12),),
  //                 //         SizedBox(height: 10,),
  //                 //         Row(
  //                 //           children: [
  //                 //
  //                 //
  //                 //           ],
  //                 //         ),
  //                 //       ],
  //                 //     ),
  //                 //   ),
  //                 //
  //                 // ),
  //                 // SizedBox(height: 10,),
  //                 Container(
  //                   width: MediaQuery.of(context).size.width * 0.91,
  //                   decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                         color: Color(0xFFBDD7D6),
  //                       )),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Metodo de pago',
  //                           style: TextStyle(
  //                               color: Color(0xFF57419D),
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 12),
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Row(
  //                           children: [
  //                             Text(
  //                                 result.paymentTypeId == 'credit_card'
  //                                     ? 'Tarjeta de credito:'
  //                                     : result.paymentTypeId == 'debit_card'
  //                                         ? 'Tarjeta de debito:'
  //                                         : result.paymentTypeId,
  //                                 style: TextStyle(
  //                                     color: Colors.black, fontSize: 12)),
  //                             SizedBox(
  //                               width: 10,
  //                             ),
  //                             Text(result.paymentMethodId,
  //                                 style: TextStyle(
  //                                     color: Colors.black, fontSize: 12)),
  //                           ],
  //                         ),
  //                         Row(
  //                           children: [
  //                             Text(
  //                               'Orden N°',
  //                               style: TextStyle(
  //                                   fontSize: 12,
  //                                   color: Color(0xFF57419D),
  //                                   fontWeight: FontWeight.bold),
  //                             ),
  //                             Text(
  //                               productId,
  //                               style: TextStyle(
  //                                   fontSize: 12, fontWeight: FontWeight.bold),
  //                             ),
  //                           ],
  //                         ),
  //                         StreamBuilder<QuerySnapshot>(
  //                             stream: FirebaseFirestore.instance
  //                                 .collection("Ordenes")
  //                                 .doc(productId)
  //                                 .collection('Items')
  //                                 .where('uid',
  //                                     isEqualTo: PetshopApp.sharedPreferences
  //                                         .getString(PetshopApp.userUID)
  //                                         .toString())
  //                                 .snapshots(),
  //                             builder: (context, dataSnapshot) {
  //                               if (!dataSnapshot.hasData) {
  //                                 return Center(
  //                                   child: CircularProgressIndicator(),
  //                                 );
  //                               }
  //                               return ListView.builder(
  //                                   physics: NeverScrollableScrollPhysics(),
  //                                   itemCount:
  //                                       dataSnapshot.data.docs.length,
  //                                   shrinkWrap: true,
  //                                   itemBuilder: (
  //                                     context,
  //                                     index,
  //                                   ) {
  //                                     ItemModel item = ItemModel.fromJson(
  //                                         dataSnapshot
  //                                             .data.docs[index].data);
  //                                     return Column(
  //                                       children: [
  //                                         SizedBox(
  //                                           child: Column(
  //                                             children: [
  //                                               Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment
  //                                                         .spaceBetween,
  //                                                 children: [
  //                                                   Expanded(
  //                                                       child: Text(item.titulo,
  //                                                           style: TextStyle(
  //                                                               fontSize: 10,
  //                                                               color: Color(
  //                                                                   0xFF57419D),
  //                                                               fontWeight:
  //                                                                   FontWeight
  //                                                                       .bold),
  //                                                           textAlign: TextAlign
  //                                                               .left)),
  //                                                   Row(
  //                                                     children: [
  //                                                       Text(
  //                                                         'S/',
  //                                                         style: TextStyle(
  //                                                             fontSize: 10,
  //                                                             color: Color(
  //                                                                 0xFF57419D),
  //                                                             fontWeight:
  //                                                                 FontWeight
  //                                                                     .bold),
  //                                                         textAlign:
  //                                                             TextAlign.left,
  //                                                       ),
  //                                                       Text(
  //                                                           item.precio
  //                                                               .toString(),
  //                                                           style: TextStyle(
  //                                                               fontSize: 16,
  //                                                               color: Color(
  //                                                                   0xFF57419D),
  //                                                               fontWeight:
  //                                                                   FontWeight
  //                                                                       .bold),
  //                                                           textAlign:
  //                                                               TextAlign.left),
  //                                                     ],
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                         Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.start,
  //                                           children: [
  //                                             Text(item.nombreComercial,
  //                                                 style:
  //                                                     TextStyle(fontSize: 10),
  //                                                 textAlign: TextAlign.left),
  //                                           ],
  //                                         ),
  //                                         Divider(
  //                                           indent: 20,
  //                                           endIndent: 20,
  //                                           color: Color(0xFF57419D)
  //                                               .withOpacity(0.5),
  //                                         ),
  //                                       ],
  //                                     );
  //                                   });
  //                             }),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text(
  //                               'Petpoints Acreditados',
  //                               style: TextStyle(
  //                                   fontSize: 12.0,
  //                                   color: Color(0xFF57419D),
  //                                   fontWeight: FontWeight.bold),
  //                             ),
  //                             Row(
  //                               mainAxisAlignment: MainAxisAlignment.end,
  //                               children: [
  //                                 Text(
  //                                   (result.transactionAmount).toString(),
  //                                   style: TextStyle(
  //                                       fontSize: 18.0,
  //                                       color: Color(0xFF57419D),
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(
  //                           height: 8,
  //                         ),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text(
  //                               'Tu cargo',
  //                               style: TextStyle(
  //                                   fontSize: 12.0,
  //                                   color: Color(0xFF57419D),
  //                                   fontWeight: FontWeight.bold),
  //                             ),
  //                             Row(
  //                               mainAxisAlignment: MainAxisAlignment.end,
  //                               children: [
  //                                 Text(
  //                                   'S/ ',
  //                                   style: TextStyle(
  //                                       fontSize: 12.0,
  //                                       color: Color(0xFF57419D),
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                                 Text(
  //                                   (result.transactionAmount).toString(),
  //                                   style: TextStyle(
  //                                       fontSize: 18.0,
  //                                       color: Color(0xFF57419D),
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //     if (result.status != 'approved') {
  //       showDialog(
  //         context: context,
  //         child: AlertDialog(
  //           title: Row(
  //             children: [
  //               Icon(
  //                 Icons.cancel,
  //                 color: Colors.red,
  //               ),
  //               SizedBox(
  //                 width: 10,
  //               ),
  //               Text(
  //                 'Su pago ha sido rechazado.',
  //                 style: TextStyle(fontSize: 14),
  //               ),
  //             ],
  //           ),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: <Widget>[
  //                 // Text('This is a demo alert dialog.'),
  //                 // Text('Would you like to approve of this message?'),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //
  //       setState(() {
  //         db
  //             .collection('Ordenes')
  //             .doc(productId)
  //             .collection('Items')
  //             .getDocuments()
  //             .then((snapshot) {
  //           for (DocumentSnapshot doc in snapshot.documents) {
  //             doc.reference.delete();
  //           }
  //           ;
  //         });
  //         db.collection('Ordenes').doc(productId).delete();
  //       });
  //     }
  //   }
  // }

  // List tempCartList = PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList);
  // tempCartList.add(itemID);
  //
  // PetshopApp.firestore.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).updateData({
  //   PetshopApp.userCartList: tempCartList,
  // }).then((v){
  //  Fluttertoast.showToast(msg: "Se ha agregado su producto al carrito.");
  //  PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, tempCartList);
  // });

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}

// // class OrderScreen extends StatefulWidget {
// //   final Map<String, dynamic> orderData;
// //
// //   const OrderScreen({Key key, this.orderData}) : super(key: key);
// //
// //   @override
// //   _OrderScreenState createState() => _OrderScreenState();
// //   }
// //
// // class _OrderScreenState extends State<OrderScreen> {
// //  bool _loading = true;
// //  String _message = "";
// //
// //  @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //     // createOrder();
// //   }
// //
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // TODO: implement build
// //    return Scaffold();
// //   }
// // }
//
//
//
// }
