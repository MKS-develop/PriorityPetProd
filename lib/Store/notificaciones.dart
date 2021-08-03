import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';

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
import 'package:http/http.dart' as http;
class NotificacionesPage extends StatefulWidget {
  final PetModel petModel;
  final Producto productoModel;
  final CartModel cartModel;
  final int defaultChoiceIndex;

  NotificacionesPage(
      {this.petModel,
      this.productoModel,
      this.cartModel,
      this.defaultChoiceIndex});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  PetModel model;
  CartModel cart;
  Producto producto;
  AliadoModel ali;
  List allResults = [];
  List ordenes = [];
  int ratingC = 0;
  bool noti = true;
  bool home = false;
  bool carrito = false;
  String _prk;

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getOrderStatus();
    _getprK();

    // initState calificarAliado();

    // try{
    //   var json = '{"first_name": "${_nameTextEditingController.text.trim()}","last_name": "${_lastnameTextEditingController.text.trim()}","address": "${_addressTextEditingController.text.trim()}","phone_number": "${_tlfTextEditingController.text.trim()}","email": "${PetshopApp.sharedPreferences.getString(PetshopApp.userEmail)}", "address_city": "Lima", "country_code": "PE"}'
    //   ;
    //   var url = ("https://api.culqi.com/v2/customers?email=jesus.salazar@capas360.com");
    //   Map<String, String> headers = {"Content-type": "application/json", 'Authorization': 'Bearer sk_test_7c6b926b8a7d65eb'};
    //   Response res = await http.get(url, headers: headers);
    //   var statusCode = await res.body;
    //   setState((){
    //     // response = statusCode.toString();
    //     print(statusCode);
    //   });
    // } catch (e){
    //   print(e.message);
    //   return null;
    // }

  }

  deleteUser() async{
    try {

      var url = ("https://api.culqi.com/v2/customers/cus_live_UpWsKodzqCv0nDZa");
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": _prk
      };
      Response res = await http.delete(Uri.parse(url), headers: headers);
      int statusCode = await res.statusCode;


      setState(() {
        // response = statusCode.toString();

        print(statusCode);
        print('el cuerpo es ${res.body}');
      });
    } catch (e) {
      print(e.message);
      return null;
    }
  }
  // calificarAliado() {
  //
  //   StreamBuilder<QuerySnapshot>(
  //       stream: FirebaseFirestore.instance.collection('Ordenes').where('uid', isEqualTo: PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).where('date', isLessThan: DateTime.now()).where('calificacion', isEqualTo: false).snapshots(),
  //       builder: (context, dataSnapshot) {
  //         if (!dataSnapshot.hasData) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //         return ListView.builder(
  //             physics: NeverScrollableScrollPhysics(),
  //             itemCount: dataSnapshot.data.docs.length,
  //             shrinkWrap: true,
  //             itemBuilder: (context, index,) {
  //               OrderModel order = OrderModel.fromJson(
  //                   dataSnapshot.data.docs[index].data());
  //               return showDialog(
  //                   context: context,
  //                   child: new ChoosePetAlertDialog(
  //                     message:
  //                     "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
  //                   ));
  //
  //             }
  //         );
  //       }
  //   );
  // }
  _getprK() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Culqi").doc("Priv");
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _prk = (dataSnapshot.data()["prk"]);
      });
        // deleteUser();
    });
  }

  Future<List<dynamic>> _getOrderStatus() async {
    List list = await FirebaseFirestore.instance
        .collection('Ordenes')
        .where("uid",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .where("calificacion", isEqualTo: false)
        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list.length; i++) {
      FirebaseFirestore.instance
          .collection('Ordenes')
          .where('oid', isEqualTo: list[i].documentID.toString())
          .where('date', isLessThan: DateTime.now())
          .snapshots()
          .listen(CreateList);
    }
    return list;
  }

  CreateList(QuerySnapshot snapshot) async {
    ordenes = [];
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        allResults.add(OrderModel.fromJson(Doc.data()));
        OrderModel order = OrderModel.fromJson(Doc.data());
        ordenes.add(order);
      });
    }
    search();
  }

  search() {
    for (int i = 0; i < ordenes.length; i++) {
      var nombreComercial = ordenes[i].nombreComercial;
      var usuario = PetshopApp.sharedPreferences.getString(PetshopApp.userName);
      //   for(OrderModel order in allResults){
      showDialog(
        builder: (context) => AlertDialog(
          // title: Text('Su pago ha sido aprobado.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '$usuario,',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  'Nos gustaría que calificaras tu último servicio con $nombreComercial, tu opinión nos importa.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 14,
                ),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingC = int.parse(rating.toStringAsFixed(0));
                    });

                    print(ratingC.toStringAsFixed(0));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      updateFields(ordenes[i].aliadoId, ordenes[i].oid);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: Color(0xFF57419D),
                    padding: EdgeInsets.all(10.0),
                    child: Text("Enviar calificación",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Colors.white,
                            fontSize: 18.0)),
                  ),
                ),
              ],
            ),
          ),
        ), context: context,
        barrierColor: Colors.white.withOpacity(0),
      );
    }
  }

  updateFields(aliadoId, oid) async {
    var ratingSum = await db.collection('Aliados').doc(aliadoId);
    ratingSum.update({
      'totalRatings':
          FieldValue.increment(int.parse(ratingC.toStringAsFixed(0))),
      'countRatings': FieldValue.increment(1),
    });

    var checkRef = await db.collection('Ordenes').doc(oid);
    checkRef.update({
      'calificacion': true,
    });
  }
  // showDialog(context: context, child:
  // AlertDialog(
  //   // title: Text('Su pago ha sido aprobado.'),
  //   content: SingleChildScrollView(
  //     child: ListBody(
  //       children: <Widget>[
  //     Text(PetshopApp.sharedPreferences.getString(PetshopApp.userName)),
  //         Text('Nos gustaría que calificaras tu último servicio con'),
  //
  //
  //
  //     RatingBar.builder(
  //     initialRating: 3,
  //       minRating: 1,
  //       direction: Axis.horizontal,
  //       allowHalfRating: true,
  //       itemCount: 5,
  //       itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //       itemBuilder: (context, _) => Icon(
  //         Icons.star,
  //         color: Colors.amber,
  //       ),
  //       onRatingUpdate: (rating) {
  //         print(rating);
  //       },
  //     ),
  //       ],
  //     ),
  //   ),),);

  // Future<List<dynamic>> _getOrderStatus() async {
  //   ordenes = []
  //   try{
  //     await FirebaseFirestore.instance.collection('Ordenes').where("uid", isEqualTo: widget.order.orderId).where("calificacion", isEqualTo: false).get().then((QuerySnapshot querySnapshot) => {
  //     querySnapshot.data.docs((orden){
  //     setState((){
  //     OrderModel order = OrderModel.fromJson(order.data);
  //     ordenes.add(order);
  //     });
  //     });
  //     });
  //   }catch(e){
  //     print(e);
  //   }
  //   if(ordenes.length > 0){
  //     for(int i = 0; i < ordenes.length; i++){
  //       var dialog = Dialog(
  //           context,
  //           child: Text(
  //               ordenes[i].titulo
  //           )
  //       );
  //       scaffoldKey.currentState.showDialog(dialog);
  //     }
  //   }
  //   return ordenes;
  // }
  //

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
          noti: noti,
          home: home,
          cart: carrito,
        ),
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
                        "Notificaciones",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
