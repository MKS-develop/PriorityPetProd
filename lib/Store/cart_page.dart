import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Product.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class CartPage extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  CartPage({this.petModel, this.defaultChoiceIndex});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int total = 0;
  PetModel model;
  bool _value = false;
  int cantidad = 1;
  int cantPet = 100;
  double valorPet = 0.1;
  double totalPet = 0;
  List<int> totalList = [];
  double sum = 0;
  Stream stream;
  int totalsum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stream = FirebaseFirestore.instance
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .snapshots();
  }

  void countDocuments() async {
    QuerySnapshot _myDoc = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    print(_myDocCount.length);
    // Count of Documents in Collection
  }

  Widget sourceInfo(
    CartModel cart,
    BuildContext context,
  ) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            producto(cart, context),
          ],
        ),
      ),
    );
  }

  Widget producto(CartModel cart, BuildContext context) {
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
                  stream: FirebaseFirestore.instance
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
                              ProductModel.fromJson(dataSnapshot.data.data);

                          int precio = product.precio * cart.cantidad;
                          //
                          //
                          // totalList.add(precio);

                          // sum = totalList.fold(0, (prev, num) => prev + num);

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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.titulo,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF57419D),
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.left),
                                      Text(
                                        product.dirigido,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '15Kg',
                                        style: TextStyle(
                                          color: Color(0xFF57419D),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Text(
                                    "\$",
                                    style: TextStyle(
                                      color: Color(0xFF57419D),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    precio.toString(),
                                    style: TextStyle(
                                      color: Color(0xFF57419D),
                                      fontSize: 18,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cart.cantidad.toString(),
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 100.0,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          FirebaseFirestore.instance
                              .collection("Dueños")
                              .doc(PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userUID))
                              .collection('Cart')
                              .doc(cart.iId)
                              .delete();
                        });
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

    totalList.forEach((precio) {
      setState(() {
        totalsum += precio;
      });
    });
    print(totalsum);

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
                        "Mi pedido",
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
                    stream: stream,
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
                            return sourceInfo(cart, context);
                          });
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub total',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            totalsum.toString(),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                                  borderRadius: BorderRadius.circular(5)),
                              color: Color(0xFFBBD7D6),
                              padding: EdgeInsets.all(0.0),
                              child: Text(cantPet.toString(),
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      color: Color(0xFF57419D),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold)),
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
                        width: 70.0,
                        child: RaisedButton(
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: Color(0xFFBBD7D6),
                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("\$",
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      color: Color(0xFF57419D),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold)),
                              Text((cantPet * valorPet).toString(),
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      color: Color(0xFF57419D),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          '¿Aplicar?',
                          style: TextStyle(
                              fontSize: 18.0,
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
                                totalPet = valorPet * cantPet;
                              } else {
                                totalPet = 0;
                              }
                            });
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descuento por PetPoints',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (totalPet).toString(),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total a cancelar',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (totalsum - totalPet).toString(),
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
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StoreHome()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Color(0xFFEB9448),
                      padding: EdgeInsets.all(10.0),
                      child: Text("Pagar",
                          style: TextStyle(
                              fontFamily: 'Product Sans',
                              color: Colors.white,
                              fontSize: 18.0)),
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

  Future totalLikes(postID) async {
    var respectsQuery = FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart');
    var querySnapshot = await respectsQuery.get();
    var totalEquals = querySnapshot.docs.length;
    print(totalEquals);
    return totalEquals;
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }
}
