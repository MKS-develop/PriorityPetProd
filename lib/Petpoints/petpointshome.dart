import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Config/config.dart';

import 'package:pet_shop/Models/Producto.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Models/petpoints.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class PetPointsHome extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  PetPointsHome(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _PetPointsHomeState createState() => _PetPointsHomeState();
}

class _PetPointsHomeState extends State<PetPointsHome> {
  PetModel model;
  CartModel cart;
  Producto producto;
  double ppvalor = 0;

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
                        "Mis Pet Points",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'Pet Points = Dinero',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '¿Cómo puedes ganar Pet Points?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                        child: Column(
                          children: [
                            Text(
                                '- Por cada ${PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda)} de compra acumulas puntos que luego podrás canjear por descuentos exclusivos o productos y servicios.'),
                            Text(
                                '- Podrás hacer donaciones o colaborar en una labor social con nuestras ONG’s aliadas.'),
                            Text(
                                '- Invitando a un amigo a formar parte de la comunidad. Ganas puntos por cada referido que se registre con tu código.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Dueños")
                        .doc(PetshopApp.sharedPreferences
                            .getString(PetshopApp.userUID))
                        .collection('Petpoints')
                        .snapshots(),
                    builder: (context, dataSnapshot) {
                      if (dataSnapshot.hasData) {
                        if (dataSnapshot.data.docs.length == 0) {
                          return Center(child: Text('NO DATA'));
                        }
                      }
                      if (!dataSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container(
                        width: _screenWidth,
                        height: _screenHeight * 0.6,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            shrinkWrap: true,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              PetpointsModel pp = PetpointsModel.fromJson(
                                  dataSnapshot.data.docs[index].data());
                              return sourceInfo(pp, context);
                            }),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceInfo(
    PetpointsModel pp,
    BuildContext context,
  ) {
    return InkWell(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //     context,
          //
          //   MaterialPageRoute(builder: (context) => OrdenesDetalle(orderModel: order)),
          // );
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30.0,
                        child: Image.asset(
                          'diseñador/drawable/petpoint.png',
                          color: Color(0xFF57419D),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PetshopApp.sharedPreferences
                                .getString(PetshopApp.userName),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Tu estado de cuenta de Pet Point'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Pet Points asignados'),
                      SizedBox(
                        width: 53,
                      ),
                      Text(
                        pp.ppGenerados.toString(),
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Pet Points acumulados'),
                      SizedBox(
                        width: 40,
                      ),
                      Text(
                        pp.ppAcumulados.toString(),
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Pet Points canjeados'),
                      SizedBox(
                        width: 53,
                      ),
                      Text(
                        pp.ppCanjeados.toString(),
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Tienes disponibles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        (pp.ppAcumulados - pp.ppCanjeados).toString(),
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Pet Points',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Valor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        ((pp.ppAcumulados - pp.ppCanjeados) * ppvalor)
                            .toStringAsPrecision(2),
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        PetshopApp.sharedPreferences
                            .getString(PetshopApp.Moneda),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
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
