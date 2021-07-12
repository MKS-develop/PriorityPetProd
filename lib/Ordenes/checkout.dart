import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class CheckOutPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;

  Future getCount({String id}) async => FirebaseFirestore.instance
          .collection('Dueños')
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart') //your collectionref
          .getDocuments()
          .then((value) {
        var count = 0;
        count = value.documents.length;
        print(count);
        return count;
      });

  CheckOutPage({this.petModel, this.productoModel, this.cartModel});

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  String _platformVersion = 'Unknown';
  PetModel model;
  CartModel cart;
  Producto producto;

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
        appBar: AppBarCustomAvatar(context, widget.petModel),
        bottomNavigationBar: CustomBottomNavigationBar(),
        drawer: MyDrawer(),
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
                        "Checkout",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Text('Running on: $_platformVersion\n'),
                //
                // RaisedButton(
                //   onPressed: () async {
                //     PaymentResult result =
                //     await MercadoPagoMobileCheckout.startCheckout("TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3", "698748168-e3a21e6a-6e36-43d3-911f-8eff284f782e",
                //     );
                //     print(result.toString());
                //   },
                //   child: Text("Pagar"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void countDocuments() async {
    final QuerySnapshot qSnap = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .getDocuments();
    final int documents = qSnap.documents.length;
    print(documents);

    QuerySnapshot _myDoc = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    print(_myDocCount.length);

    // Count of Documents in Collection
  }
}
