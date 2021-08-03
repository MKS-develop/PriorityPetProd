import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Store/notificaciones.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/cart/cartfinal.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final noti, home, cart;
  final PetModel petmodel;
  final int defaultChoiceIndex;

  CustomBottomNavigationBar({this.noti, this.home, this.cart, this.petmodel, this.defaultChoiceIndex});
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int counterN = 0;
  int counterNoti = 0;
  List<CartModel> carrito = [];
  List totalList = [];
  bool home;
  bool noti;
  bool cart;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getOrders();
    MastersList();
    // ModalRoute.of(context).settings.name;
    // var route = ModalRoute.of(context);
    //
    // if(route!=null){
    //   print('el nombre de la ruta es${route.settings.name}');
    // }
    if(widget.home !=null){
      setState(() {
        home=widget.home;
      });
    }
    else{
      setState(() {
        home=false;
      });
    }
    if(widget.noti !=null){
      setState(() {
        noti=widget.noti;
      });
    }
    else{
      setState(() {
        noti=false;
      });
    }
    if(widget.cart !=null){
      setState(() {
        cart=widget.cart;
      });
    }
    else{
      setState(() {
        cart=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
      height: 55.0,
      decoration: new BoxDecoration(color: Colors.white, boxShadow: [
        new BoxShadow(
          color: Colors.grey,
          blurRadius: 10.0,
        ),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(

              autofocus: true,
              icon: Icon(
                Icons.home,
                color: home? Color(0xFF57419D) : Color(0xFF57419D).withOpacity(0.5),
                size: 27.0,
              ),
              onPressed: () {
                if(home!=true) {
                  // Route route = MaterialPageRoute(builder: (c) => StoreHome());
                  // Navigator.pushReplacement(context, route);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoreHome(petModel: widget.petmodel, defaultChoiceIndex: widget.defaultChoiceIndex)),
                  );
                }
                setState(() {
                  home = true;
                  noti = false;
                  cart= false;
                });

              }),

          IconButton(
              icon: Badge(
                badgeContent: Text(
                  counterNoti.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                badgeColor: counterNoti == 0 ? Colors.transparent : Colors.red,
                elevation: 0,
                child: Image.asset(
                  'diseñador/drawable/Grupo82.png',
                  color: noti? Color(0xFF57419D) : Color(0xFF57419D).withOpacity(0.5),
                  height: 30.0,
                ),
              ),
              onPressed: () {
                if(noti!=true){
                  // Route route = MaterialPageRoute(builder: (c) => NotificacionesPage());
                  // Navigator.pushReplacement(context, route);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificacionesPage(petModel: widget.petmodel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
                  );
                }
                setState(() {
                  home = false;
                  noti = true;
                  cart= false;
                });


              }),
          IconButton(
              icon: Badge(
                badgeContent: Text(
                  totalList.length.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                badgeColor:
                totalList.length == 0 ? Colors.transparent : Colors.green,
                elevation: 0,
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: cart? Color(0xFF57419D) : Color(0xFF57419D).withOpacity(0.5),
                  size: 27.0,
                ),
              ),
              onPressed: () {
                if(cart!=true) {
                  // Route route = MaterialPageRoute(builder: (c) => CartFinal());
                  // Navigator.pushReplacement(context, route);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartFinal(petModel: widget.petmodel, defaultChoiceIndex: widget.defaultChoiceIndex,)),
                  );
                }
                setState(() {
                  home = false;
                  noti = false;
                  cart= true;
                });

              }),

          // Icon(Icons.shopping_cart_rounded, color: Color(0xFF57419D), size: 27.0,
        ],
      ),
    );
  }
  // Future<dynamic> getOrders() async {
  //
  //   try{
  //     await FirebaseFirestore.instance.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).collection('Cart').getDocuments().then((QuerySnapshot querySnapshot) => {
  //       querySnapshot.documents.forEach((order) {
  //         setState((){
  //           CartModel cart = CartModel.fromJson(order.data);
  //           carrito.add(cart);
  //           counterN = carrito.length;
  //         });
  //       })
  //     });
  //
  //     // print(ordenes);
  //   }catch(e){
  //     print(e);
  //   }
  // }

  MastersList() async {
    List list_of_locations = await FirebaseFirestore.instance
        .collection('Dueños')
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection('Cart')
        .get()
        .then((val) => val.docs);

    for (int i = 0; i < list_of_locations.length; i++) {
      FirebaseFirestore.instance
          .collection("Dueños")
          .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection('Cart')
          .doc(list_of_locations[i].documentID.toString())
          .collection("Items")
          .snapshots()
          .listen(CreateListofServices);
    }
    return list_of_locations;
  }

  CreateListofServices(QuerySnapshot snapshot) async {
    setState(() {
      counterN = snapshot.docs.length;
    });

    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        totalList.add(1);
      });
    }
  }

// suma(subtotal){
//   totalList.add(subtotal);
//
//   totalList.forEach((subtotal){
//
//     // totalsum = totalList.fold(0, (prev, num) => prev + num);
//
//
//   });
//   print(totalsum);
//   return totalsum;
// }

}
