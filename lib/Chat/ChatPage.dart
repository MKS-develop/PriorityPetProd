import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
//import 'file:///Users/jesussalazar/Documents/Dev/FlutterProjects/PriorityPetProd/lib/Models/Chats.dart';
import 'package:pet_shop/Models/Message.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/ktitle.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';

class ChatPage extends StatefulWidget {
  final PetModel petModel;
  final AliadoModel aliadoModel;
  final OrderModel orderModel;
  final String aliado;
  final int defaultChoiceIndex;

  ChatPage(
      {this.petModel,
      this.aliadoModel,
      this.orderModel,
      this.aliado,
      this.defaultChoiceIndex});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  PetModel model;
  final db = FirebaseFirestore.instance;
  final pushProvider = PushNotificationsProvider();
  TextEditingController textController = TextEditingController();
  String message;
  final ScrollController _scrollController = ScrollController();
  String aliado;
  @override
  void initState() {
    super.initState();
    setState(() {
      aliado = widget.aliado;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
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
            horizontal: 0.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     IconButton(
                      //         icon: Icon(Icons.arrow_back_ios,
                      //             color: Color(0xFF57419D)),
                      //         onPressed: () {
                      //           Navigator.pop(context);
                      //         }),
                      //     Padding(
                      //       padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      //       child: Text(
                      //         "Mensajería",
                      //         style: TextStyle(
                      //           color: Color(0xFF57419D),
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Container(
                        color: Colors.white70,
                        // padding:
                        // EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                              ),
                              IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      color: Color(0xFF57419D)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("Aliados")
                                      .doc(aliado)
                                      .snapshots(),
                                  // ignore: missing_return
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Text("Cargando...");
                                    }
                                    return Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: Image.network(
                                              snapshot.data["avatar"],
                                              errorBuilder: (context, object, stacktrace) {
                                                return Container();
                                              },
                                            ).image ?? 'Cargando',
                                          ),
                                        ),
                                        SizedBox(
                                          width: 9,
                                        ),
                                        Text(snapshot.data["nombre"],
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 19.0)),
                                      ],
                                    );
                                  })
                            ]),
                      ),
                      Container(
                        height: _screenHeight * 0.59,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("Chats")
                                  .doc(aliado +
                                      PetshopApp.sharedPreferences
                                          .getString(PetshopApp.userUID))
                                  .collection("Mensajes")
                                  .orderBy("createdOn")
                                  .snapshots(),
                              // ignore: missing_return
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data.docs.length == 0) {
                                  return Center(
                                      child: Column(children: [
                                    SizedBox(
                                      height: 200,
                                    ),
                                    Text(
                                      'No tienes chats activos en este momento...',
                                      style: TextStyle(
                                          color: Color(0xFF7F9D9D),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.0),
                                    ),
                                  ]));
                                }
                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: snapshot.data.docs.length,
                                  shrinkWrap: true,
                                  // reverse: true,
                                  // physics: BouncingScrollPhysics(),

                                  itemBuilder: (context, i) {
                                    MessageModel mensaje =
                                        MessageModel.fromJson(
                                            snapshot.data.docs[i].data());
                                    return MessageWidget(context, mensaje);
                                  },
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 70.0,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: textController,
                        onChanged: (val) => message = val,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Enviar mensaje ...",
                          border: InputBorder.none,
                        ),
                      )),
                      IconButton(
                        icon: Icon(Icons.send),
                        color: Color(0xFF57419D),
                        iconSize: 25.0,
                        onPressed: () {
                          sendMessage();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _dialogCompleto(BuildContext context, String messageId) async {
    double width = MediaQuery.of(context).size.width;

    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 220,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 60.0),
                    SizedBox(height: 20.0),
                    Text(
                      "¿Seguro deseas eliminar este mensaje?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Cancelar',
                                        style: TextStyle(color: textColor)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                deleteMessage(messageId);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Eliminar',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]))
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future deleteMessage(messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(aliado +
              PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection("Mensajes")
          .doc(messageId)
          .delete()
          .then((value) {});
    } catch (e) {
      print("Error: $e");
    }
  }

  getTime(time) {
    var t;
    var format = DateFormat.jm('es_VE');
    t = format.format(time);
    return t;
  }

  Future sendMessage() async {
    User user = await FirebaseAuth.instance.currentUser;
    try {
      // _scrollController.animateTo(
      //     _scrollController.position.maxScrollExtent,
      //     duration: Duration(milliseconds: 200),
      //     curve: Curves.easeInOut
      // );
      String id = FirebaseFirestore.instance
          .collection('Chats')
          .doc(aliado +
              PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection("Mensajes")
          .doc()
          .id
          .toString();
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(aliado +
              PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .set({
        "chatId":
            aliado + PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
        "aliadoId": aliado,
        "uid": PetshopApp.sharedPreferences.get(PetshopApp.userUID),
      });
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(aliado +
              PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
          .collection("Mensajes")
          .doc(id)
          .set({
        "messageId": id,
        "aliadoId": aliado,
        "uid": PetshopApp.sharedPreferences.get(PetshopApp.userUID),
        "message": message,
        "createdOn": FieldValue.serverTimestamp(),
        "status": false,
      });
      pushProvider.sendMessageNotificaction(aliado, message);
      textController.clear();
      print("Enviado");
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget MessageWidget(BuildContext context, MessageModel mensaje) {
    return GestureDetector(
      onLongPress: () {
        _dialogCompleto(context, mensaje.messageId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: mensaje.uid == null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: mensaje.uid == null ? textColor : primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: mensaje.uid == null
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      mensaje.message,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            mensaje.createdOn != null
                                ? getTime(mensaje.createdOn.toDate())
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          mensaje.uid == null
                              ? Icon(Icons.check, color: Colors.transparent)
                              : Icon(Icons.check, color: Color(0xFF7F9D9D)),
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
