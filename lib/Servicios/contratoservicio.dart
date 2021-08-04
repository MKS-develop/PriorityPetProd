import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/daymodel.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Ordenes/ordeneshome.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

int cantidad = 1;

double width;

class ContratoServicio extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final int defaultChoiceIndex;
  ContratoServicio(
      {this.petModel,
      this.serviceModel,
      this.aliadoModel,
      this.locationModel,
      this.defaultChoiceIndex});

  @override
  _ContratoServicioState createState() => _ContratoServicioState();
}

class _ContratoServicioState extends State<ContratoServicio> {
  final pushProvider = PushNotificationsProvider();
  bool _checked = false;
  Timestamp date;
  dynamic totalPet = 0;
  String hora;
  String fecha = '0';
  dynamic recojo = 0;
  dynamic delivery = 0;
  int _defaultChoiceIndex;
  int _2defaultChoiceIndex;
  bool _value = false;
  bool _value2 = false;
  AliadoModel ali;
  LocationModel location;
  DateTime selectedDate = DateTime.now();
  ServiceModel servicio;
  PetModel model;
  PromotionModel pro;
  CartModel cart;
  bool select = false;
  bool uploading = false;
  String petImageUrl = "";
  String downloadUrl = "";
  BuildContext dialogContext;
  int ppAcumulados = 0;
  int ppCanjeados = 0;
  double ppvalor = 0;
  String tituloCategoria = "Servicio";
  dynamic _totalPrice;

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    changePet(widget.petModel);
    changePro(widget.serviceModel);
    changeAli(widget.aliadoModel);
    changeLoc(widget.locationModel);
    sendEmail(PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        'Jesus Salazar', '2342424', 'www');

    deleteDate();

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
    http.get(Uri.parse('https://us-central1-priority-pet.cloudfunctions.net/sendOrderDuenoEmail?dest=jesusgsb@gmail.com'));
  }

  // eliminarFecha(){
  //   var val=[];   //blank list for add elements which you want to delete
  //   val.add(day.horasDia[i]);
  //   FirebaseFirestore.instance.collection("INTERESTED").doc('documentID').updateData({
  //
  //     "Interested Request":FieldValue.arrayRemove(val) });
  // }
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

  sendEmail(_email, nombreCompleto, orderId, aliadoAvatar) async {
    await http.get(
        Uri.parse('https://us-central1-priority-pet.cloudfunctions.net/sendOrderDuenoEmail?dest=$_email&username=$nombreCompleto&orderId=$orderId&logoAliado=$aliadoAvatar'));
    print('$_email $nombreCompleto $orderId $aliadoAvatar');
  }

  sendEmail2(_email, nombreCompleto) async {
    await http.get(
        Uri.parse('https://us-central1-priority-pet.cloudfunctions.net/sendWelcomeEmailDuenos?dest=$_email&username=$nombreCompleto'));
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    //initializeDateFormatting("es_VE", null).then((_) {});
    var formatter = DateFormat.yMMMMEEEEd('es_VE');
    String formatted = formatter.format(DateTime.now());

    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    double rating =
        widget.aliadoModel.totalRatings / widget.aliadoModel.countRatings;

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
                        "Contrato de servicio",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        widget.aliadoModel.avatar,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      height: 100.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(widget.aliadoModel.nombreComercial,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          Text(widget.locationModel.direccionLocalidad,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.left),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  rating.toString() != 'NaN'
                                      ? rating.toStringAsPrecision(2)
                                      : '0',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.orange),
                                  textAlign: TextAlign.left),
                              Icon(
                                Icons.star,
                                color: Colors.orange,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                widget.serviceModel.domicilio != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Servicio a domicilio',
                            style: TextStyle(
                                color: Color(0xFF7F9D9D), fontSize: 16),
                          ),
                          Row(
                            children: [
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
                                (widget.serviceModel.domicilio).toStringAsFixed(2) !=
                                        'null'
                                    ? (widget.serviceModel.domicilio).toStringAsFixed(2)
                                    : '0',
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                  value: _value,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value = value;
                                      if (value == true) {
                                        if (widget.serviceModel.domicilio ==
                                            null) {
                                          recojo = 0;
                                        } else {
                                          recojo =
                                              widget.serviceModel.domicilio;
                                        }

                                        _value2 = false;
                                        delivery = 0;
                                      } else {
                                        recojo = 0;
                                      }
                                    });
                                  }),
                            ],
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                widget.serviceModel.delivery != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recoger a tu mascota',
                            style: TextStyle(
                                color: Color(0xFF7F9D9D), fontSize: 16),
                          ),
                          Row(
                            children: [
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
                                (widget.serviceModel.delivery).toStringAsFixed(2) !=
                                        'null'
                                    ? (widget.serviceModel.delivery).toStringAsFixed(2)
                                    : '0',
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                  value: _value2,
                                  activeColor: Color(0xFF57419D),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _value2 = value;
                                      if (value == true) {
                                        if (widget.serviceModel.delivery ==
                                            null) {
                                          delivery = 0;
                                        } else {
                                          delivery =
                                              widget.serviceModel.delivery;
                                        }

                                        _value = false;
                                        recojo = 0;
                                      } else {
                                        delivery = 0;
                                      }
                                    });
                                  }),
                            ],
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                        widget.serviceModel.tipoAgenda == 'Slots'
                            ? 'Seleccione la fecha disponible'
                            : 'Seleccione la fecha disponible',
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  child: Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: db
                              .collection("Localidades")
                              .doc(widget.serviceModel.localidadId)
                              .collection("Servicios")
                              .doc(widget.serviceModel.servicioId)
                              .collection("Agenda")
                              .where('date', isGreaterThan: DateTime.now())
                              .snapshots(),
                          // .where('date', isGreaterThan: DateTime.now())

                          builder: (context, dataSnapshot) {
                            if (dataSnapshot.hasData) {
                              if (dataSnapshot.data.docs.length == 0) {
                                return Center(child: Text(''));
                              }
                            }
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Container(
                              child: Expanded(
                                child: ListView.builder(
                                  itemCount: dataSnapshot.data.docs.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    PromotionModel pro =
                                        PromotionModel.fromJson(dataSnapshot
                                            .data.docs[index]
                                            .data());
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ChoiceChip(
                                        label: sourceInfo(pro, context),
                                        labelPadding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        selected: _defaultChoiceIndex == index,
                                        selectedColor: Color(0xFFEB9448),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _defaultChoiceIndex =
                                                selected ? index : 0;
                                            print(pro.fecha);
                                            fecha = pro.fecha;
                                            date = pro.date;
                                          });
                                        },
                                        backgroundColor: Colors.transparent,
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                                color: Color(0xFFBDD7D6))),
                                        labelStyle: TextStyle(
                                            color: Colors.transparent),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                widget.serviceModel.tipoAgenda == 'Slots' || date == '0'
                    ? Container(
                        width: _screenWidth,
                        child: Column(
                          children: [
                            fecha != '0'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('Seleccione horario disponible',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color(0xFF57419D),
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.left),
                                    ],
                                  )
                                : Container(),
                            StreamBuilder<QuerySnapshot>(
                                stream: db
                                    .collection("Localidades")
                                    .doc(widget.serviceModel.localidadId)
                                    .collection("Servicios")
                                    .doc(widget.serviceModel.servicioId)
                                    .collection("Agenda")
                                    .where('fecha', isEqualTo: fecha)
                                    .snapshots(),
                                builder: (context, dataSnapshot) {
                                  if (dataSnapshot.hasData) {
                                    if (dataSnapshot.data.docs.length == 0) {
                                      return Center(child: Text(''));
                                    }
                                  }
                                  if (!dataSnapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return Container(
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: 1,
                                        shrinkWrap: true,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          DayModel day = DayModel.fromJson(
                                              dataSnapshot.data.docs[index]
                                                  .data());
                                          return Container(
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: day.horasDia.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 4,
                                                      crossAxisSpacing: 5),
                                              // mainAxisSpacing: 10),
                                              physics: BouncingScrollPhysics(),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
                                                return ChoiceChip(
                                                  label: sourceInfo2(
                                                      context, day, i),
                                                  labelPadding:
                                                      EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  selected:
                                                      _2defaultChoiceIndex == i,
                                                  selectedColor:
                                                      Color(0xFFEB9448),
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        _2defaultChoiceIndex =
                                                            i;
                                                        print(day.horasDia[i]);
                                                        hora = day.horasDia[i];
                                                      }
                                                    });
                                                  },
                                                  shape: StadiumBorder(
                                                      side: BorderSide(
                                                          color: Color(
                                                              0xFFBDD7D6))),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  labelStyle: TextStyle(
                                                      color: Colors.white),
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                  );
                                }),
                          ],
                        ),
                      )
                    : Container(),
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais) ==
                        "Perú"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200.0,
                            child: RaisedButton(
                              onPressed: () {
                                if (fecha == null &&
                                    widget.serviceModel.tipoAgenda == 'Free') {
                                  showDialog(
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Seleccione una fecha.',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ), context: context,
                                  );
                                } else if (fecha != null &&
                                    widget.serviceModel.tipoAgenda == 'Free') {
                                  // AddOrder(widget.serviceModel.servicioId, context);
                                  _totalPrice = (widget.serviceModel.precio +
                                          recojo +
                                          delivery -
                                          totalPet)
                                      .toInt();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PaymentPage(
                                            petModel: widget.petModel,
                                            aliadoModel: widget.aliadoModel,
                                            serviceModel: widget.serviceModel,
                                            locationModel: widget.locationModel,
                                            tituloCategoria: tituloCategoria,
                                            totalPrice: _totalPrice,
                                            hora: hora,
                                            fecha: fecha,
                                            recojo: recojo,
                                            delivery: delivery,
                                            value2: _value2,
                                            value: _value,
                                            date: date,
                                            defaultChoiceIndex:
                                                widget.defaultChoiceIndex,
                                            onSuccess: _respuestaPago,
                                          )),
                                  );
                                } else if (widget.serviceModel.tipoAgenda ==
                                    'Slots') {
                                  if (hora == null) {
                                    showDialog(
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Seleccione una hora.',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ), context: context,
                                    );
                                  }
                                  if (fecha == null) {
                                    showDialog(
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Seleccione una fecha.',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ), context: context,
                                    );
                                  }
                                  if (hora != null && fecha != null) {
                                    // AddOrder(widget.serviceModel.servicioId, context);
                                    _totalPrice =
                                        (widget.serviceModel.precio +
                                                recojo +
                                                delivery -
                                                totalPet)
                                            .toInt();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentPage(
                                              petModel: widget.petModel,
                                              aliadoModel: widget.aliadoModel,
                                              serviceModel: widget.serviceModel,
                                              locationModel: widget.locationModel,
                                              tituloCategoria: tituloCategoria,
                                                totalPrice: _totalPrice,
                                                hora: hora,
                                                fecha: fecha,
                                                recojo: recojo,
                                                delivery: delivery,
                                                value2: _value2,
                                                value: _value,
                                                date: date,
                                              defaultChoiceIndex:
                                              widget.defaultChoiceIndex,
                                              onSuccess: _respuestaPago,
                                              )),
                                    );
                                  }
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              color: Color(0xFFEB9448),
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Contratar servicio",
                                      style: TextStyle(
                                          fontFamily: 'Product Sans',
                                          color: Colors.white,
                                          fontSize: 18.0)),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
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
                                (widget.serviceModel.precio +
                                        recojo +
                                        delivery -
                                        totalPet)
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                  color: Color(0xFF57419D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(),
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

  changeAli(otro) {
    setState(() {
      ali = otro;
    });
    return otro;
  }

  changePro(otro) {
    setState(() {
      servicio = otro;
    });
    return otro;
  }

  changeLoc(Det) {
    setState(() {
      location = Det;
    });
    return Det;
  }

  Widget sourceInfo(PromotionModel pro, BuildContext context) {
    return InkWell(
      child: Container(
        height: 72.0,
        width: 72.0,
        child: Row(
          children: [
            Container(
              width: 68,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
                    child: Text(
                      pro.fecha,
                      style: TextStyle(
                          color: pro.fecha == fecha
                              ? Colors.white
                              : Color(0xFF7F9D9D),
                          fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sourceInfo2(BuildContext context, DayModel day, int i) {
    return InkWell(
      child: Container(
        height: 40.0,
        width: 70.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  day.horasDia[i],
                  style: TextStyle(
                      color: day.horasDia[i] == hora
                          ? Colors.white
                          : Color(0xFF7F9D9D),
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respuestaPago(String pagoId, String estadoPago, int montoAprobado) async {
    int petPoints = 0;

    String estadoOrden;
    if(estadoPago == PagoEnum.pagoAprobado) {
      estadoOrden = OrdenEnum.aprobada;
      petPoints = _totalPrice;
    }
    else {
      estadoOrden = OrdenEnum.pendiente;
    }

    Navigator.of(context, rootNavigator: true).pop();
    //OrderMessage(context, outcomeMsg);
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference
        .collection('Items')
        .doc(widget.serviceModel.servicioId)
        .set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": widget.serviceModel.titulo,
      "oid": productId,
      "aliadoId": widget.serviceModel.aliadoId,
      "servicioid": widget.serviceModel.servicioId,
      "date": date,
      "hora": hora,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "precio": _totalPrice,
      "mid": widget.petModel.mid,
      "tieneDelivery": _value2,
      "delivery": delivery,
      "tieneDomicilio": _value,
      "domicilio": recojo,
      "nombre": widget.petModel.nombre,
    });
    databaseReference.set({
      "culqiOrderId": pagoId,
      "aliadoId": widget.serviceModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": _totalPrice,
      "tipoOrden": 'Servicio',
      'createdOn': DateTime.now(),
      "status": estadoOrden,
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "ppGeneradosD": int.parse((_totalPrice).toString()),
      "date": date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "localidadId": widget.locationModel.localidadId,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StoreHome()),
      (Route<dynamic> route) => false,
    );
    sendEmail(
        PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
        PetshopApp.sharedPreferences.getString(PetshopApp.userName),
        productId,
        ali.avatar);
    pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    var val = []; //blank list for add elements which you want to delete
    val.add(hora);
    db
        .collection("Localidades")
        .doc(widget.serviceModel.localidadId)
        .collection("Servicios")
        .doc(widget.serviceModel.servicioId)
        .collection("Agenda")
        .doc(fecha)
        .update({
      "horasDia": FieldValue.arrayRemove(val),
      "horasReservadas": FieldValue.arrayUnion(val),
    });

    var likeRef = db
        .collection("Dueños")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
        .collection("Petpoints")
        .doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    likeRef.update({
      'ppAcumulados': FieldValue.increment(petPoints),
      'ppCanjeados': _value == true
          ? FieldValue.increment(ppAcumulados)
          : FieldValue.increment(0),
    });
  }



  deleteDate() {
    var a = DateTime.now();
    final b = a.toLocal();
    var dateFormat = DateFormat("yMMMMEEEEd");
    print(a);
    String tactualDate = dateFormat.format(b);
    print(tactualDate);
  }

  AddOrder(String itemID, BuildContext context) async {
    var databaseReference =
        FirebaseFirestore.instance.collection('Ordenes').doc(productId);

    databaseReference.collection('Items').doc(itemID).set({
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "petthumbnailUrl": widget.petModel.petthumbnailUrl,
      "titulo": widget.serviceModel.titulo,
      "oid": productId,
      "aliadoId": widget.serviceModel.aliadoId,
      "servicioid": itemID,
      "date": date,
      "hora": hora,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "precio": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "mid": widget.petModel.mid,
      "tieneDelivery": _value2,
      "delivery": delivery,
      "tieneDomicilio": _value,
      "domicilio": recojo,
      "nombre": widget.petModel.nombre,
    });
    databaseReference.set({
      "aliadoId": widget.serviceModel.aliadoId,
      "oid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "precio": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "tipoOrden": 'Servicio',
      'createdOn': DateTime.now(),
      "status": "Por confirmar",
      "statusCita": "Por confirmar",
      "mid": widget.petModel.mid,
      "fecha": fecha == null ? fecha : fecha.trim(),
      "ppGeneradosD": int.parse(
          (widget.serviceModel.precio + recojo + delivery).toString()),
      "date": date,
      "calificacion": false,
      "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
      "nombreComercial": widget.aliadoModel.nombreComercial,
      "localidadId": widget.locationModel.localidadId,
      "pais": PetshopApp.sharedPreferences.getString(PetshopApp.userPais),
    });
    // then((value) => databaseReference.snapshots().listen(onData));
    // sendEmail(
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //     PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //     productId,
    //     ali.avatar);
    // sendEmail(PetshopApp.sharedPreferences.getString(PetshopApp.userEmail), PetshopApp.sharedPreferences.getString(PetshopApp.userName), productId, ali.avatar);
    // var val=[];   //blank list for add elements which you want to delete
    // val.add(hora);
    // db.collection("Localidades").doc(widget.serviceModel.localidadId).collection("Servicios").doc(widget.serviceModel.servicioId)
    //     .collection("Agenda").doc(fecha).updateData({
    //
    //   "horasDia":FieldValue.arrayRemove(val) });

    // var result = await MercadoPagoMobileCheckout.startCheckout("TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3", "698748168-e3a21e6a-6e36-43d3-911f-8eff284f782e");
  }

// addItemtoCart(String itemID, String cant, String precio, BuildContext context)
// {
//
//   final databaseReference = FirebaseFirestore.instance;
//   databaseReference.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).collection('Cart').doc(productId)
//       .setData({
//     "aliadoid": widget.aliadoModel.aliadoId,
//     "oid": productId,
//     "uid":  PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
//     "precio": int.parse(precio),
//     "cantidad": int.parse(cant),
//     "productoId": itemID,
//     "mid": widget.petModel.mid,
//     "createdOn": DateTime.now(),
//     "promoid": widget.promotionModel.promoid,
//     "status": "Por confirmar",
//
//
//   });
//
//   setState(() {
//     productId = DateTime.now().millisecondsSinceEpoch.toString();
//   });

// List tempCartList = PetshopApp.sharedPreferences.getStringList(PetshopApp.userCartList);
// tempCartList.add(itemID);
//
// PetshopApp.firestore.collection('Dueños').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).updateData({
//   PetshopApp.userCartList: tempCartList,
// }).then((v){
//  Fluttertoast.showToast(msg: "Se ha agregado su producto al carrito.");
//  PetshopApp.sharedPreferences.setStringList(PetshopApp.userCartList, tempCartList);
// });
// }
//
//
//
//
// }
//
//

  void onData(DocumentSnapshot event) async {
    // if(event.data['status'] == 'pagada') {
    //   setState(() {
    //     _loading = false;
    //     _message = event.data['message'];
    //   });
    // }
    //  setState(() {
    //    procesando = true;
    //  });
    //
    //  if(procesando == true) {
    //    showDialog(context: context, child:
    //    new ChoosePetAlertDialog(message: "Procesando su pago, por favor espere...",)
    //    );
    //  }
    // showDialog(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (BuildContext context) {
    //     dialogContext = context;
    //     return Dialog(
    //       child: SizedBox(
    //         height: 100,
    //         child: new Column(
    //           children: [
    //             new SizedBox(height: 30,),
    //             new CircularProgressIndicator(),
    //             new SizedBox(height: 10,),
    //             new Text("Procesando su orden, por favor espere..."),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );

    print(event.data);
    // if (event.data['preference_id'] != null) {
    //   // Navigator.pop(dialogContext);
    //   // Navigator.of(context, rootNavigator: true).pop();
    //   var result = await MercadoPagoMobileCheckout.startCheckout(
    //       "TEST-8d555c1f-5e09-4a3c-965e-ff03867c55b3",
    //       event.data['preference_id']);
    //
    //   print(result);
    //
    //   if (result.status == 'approved') {
    //     sendEmail(
    //         PetshopApp.sharedPreferences.getString(PetshopApp.userEmail),
    //         PetshopApp.sharedPreferences.getString(PetshopApp.userName),
    //         productId,
    //         ali.avatar);
    //     pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
    //     var val = []; //blank list for add elements which you want to delete
    //     val.add(hora);
    //     db
    //         .collection("Localidades")
    //         .doc(widget.serviceModel.localidadId)
    //         .collection("Servicios")
    //         .doc(widget.serviceModel.servicioId)
    //         .collection("Agenda")
    //         .doc(fecha)
    //         .updateData({
    //       "horasDia": FieldValue.arrayRemove(val),
    //       "horasReservadas": FieldValue.arrayUnion(val),
    //     });
    //
    //     var likeRef = db
    //         .collection("Dueños")
    //         .doc(
    //             PetshopApp.sharedPreferences.getString(PetshopApp.userUID))
    //         .collection("Petpoints")
    //         .doc(
    //             PetshopApp.sharedPreferences.getString(PetshopApp.userUID));
    //     likeRef.updateData({
    //       'ppAcumulados':
    //           FieldValue.increment(int.parse(result.transactionAmount)),
    //       'ppCanjeados': _value == true
    //           ? FieldValue.increment(ppAcumulados)
    //           : FieldValue.increment(0),
    //     });
    //     FirebaseFirestore.instance.collection('Ordenes').doc(productId).updateData(
    //         {'preference_id': FieldValue.delete()}).whenComplete(() {});
    //
    //     showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         // title: Text('Su pago ha sido aprobado.'),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Container(
    //                 width: MediaQuery.of(context).size.width * 0.91,
    //                 decoration: BoxDecoration(
    //                     color: Color(0xFF57419D),
    //                     borderRadius: BorderRadius.circular(10),
    //                     border: Border.all(
    //                       color: Color(0xFFBDD7D6),
    //                     )),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Column(
    //                     children: [
    //                       Text(
    //                         'Tu pago ha sido procesado con éxito.',
    //                         style: TextStyle(
    //                             color: Colors.white,
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 12),
    //                       ),
    //                       SizedBox(
    //                         height: 10,
    //                       ),
    //                       Text(
    //                           'Pronto recibirás un correo con la confirmación de tu compra.. ',
    //                           style:
    //                               TextStyle(color: Colors.white, fontSize: 12)),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               SizedBox(
    //                 height: 10,
    //               ),
    //               // Container(
    //               //   width: MediaQuery.of(context).size.width*0.91,
    //               //   decoration: BoxDecoration(
    //               //       color: Colors.white,
    //               //       borderRadius: BorderRadius.circular(10),
    //               //       border: Border.all(color: Color(0xFFBDD7D6),)),
    //               //   child: Padding(
    //               //     padding: const EdgeInsets.all(8.0),
    //               //     child: Column(
    //               //       crossAxisAlignment: CrossAxisAlignment.start,
    //               //       children: [
    //               //         Text('Items', style: TextStyle(color: Color(0xFF57419D), fontWeight: FontWeight.bold, fontSize: 12),),
    //               //         SizedBox(height: 10,),
    //               //         Row(
    //               //           children: [
    //               //
    //               //
    //               //           ],
    //               //         ),
    //               //       ],
    //               //     ),
    //               //   ),
    //               //
    //               // ),
    //               // SizedBox(height: 10,),
    //               Container(
    //                 width: MediaQuery.of(context).size.width * 0.91,
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(10),
    //                     border: Border.all(
    //                       color: Color(0xFFBDD7D6),
    //                     )),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         'Metodo de pago',
    //                         style: TextStyle(
    //                             color: Color(0xFF57419D),
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 12),
    //                       ),
    //                       SizedBox(
    //                         height: 10,
    //                       ),
    //                       Row(
    //                         children: [
    //                           Text(
    //                               result.paymentTypeId == 'credit_card'
    //                                   ? 'Tarjeta de credito:'
    //                                   : result.paymentTypeId == 'debit_card'
    //                                       ? 'Tarjeta de debito:'
    //                                       : result.paymentTypeId,
    //                               style: TextStyle(
    //                                   color: Colors.black, fontSize: 12)),
    //                           SizedBox(
    //                             width: 10,
    //                           ),
    //                           Text(result.paymentMethodId,
    //                               style: TextStyle(
    //                                   color: Colors.black, fontSize: 12)),
    //                         ],
    //                       ),
    //                       Row(
    //                         children: [
    //                           Text(
    //                             'Orden N°',
    //                             style: TextStyle(
    //                                 fontSize: 12,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Text(
    //                             productId,
    //                             style: TextStyle(
    //                                 fontSize: 12, fontWeight: FontWeight.bold),
    //                           ),
    //                         ],
    //                       ),
    //                       StreamBuilder<QuerySnapshot>(
    //                           stream: FirebaseFirestore.instance
    //                               .collection("Ordenes")
    //                               .doc(productId)
    //                               .collection('Items')
    //                               .where('uid',
    //                                   isEqualTo: PetshopApp.sharedPreferences
    //                                       .getString(PetshopApp.userUID)
    //                                       .toString())
    //                               .snapshots(),
    //                           builder: (context, dataSnapshot) {
    //                             if (!dataSnapshot.hasData) {
    //                               return Center(
    //                                 child: CircularProgressIndicator(),
    //                               );
    //                             }
    //                             return ListView.builder(
    //                                 physics: NeverScrollableScrollPhysics(),
    //                                 itemCount:
    //                                     dataSnapshot.data.docs.length,
    //                                 shrinkWrap: true,
    //                                 itemBuilder: (
    //                                   context,
    //                                   index,
    //                                 ) {
    //                                   ItemModel item = ItemModel.fromJson(
    //                                       dataSnapshot
    //                                           .data.documents[index].data);
    //                                   return Column(
    //                                     children: [
    //                                       SizedBox(
    //                                         child: Column(
    //                                           children: [
    //                                             Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Expanded(
    //                                                     child: Text(item.titulo,
    //                                                         style: TextStyle(
    //                                                             fontSize: 10,
    //                                                             color: Color(
    //                                                                 0xFF57419D),
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold),
    //                                                         textAlign: TextAlign
    //                                                             .left)),
    //                                                 Row(
    //                                                   children: [
    //                                                     Text(
    //                                                       'S/',
    //                                                       style: TextStyle(
    //                                                           fontSize: 10,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                       textAlign:
    //                                                           TextAlign.left,
    //                                                     ),
    //                                                     Text(
    //                                                         item.precio
    //                                                             .toString(),
    //                                                         style: TextStyle(
    //                                                             fontSize: 16,
    //                                                             color: Color(
    //                                                                 0xFF57419D),
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold),
    //                                                         textAlign:
    //                                                             TextAlign.left),
    //                                                   ],
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                       Row(
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.start,
    //                                         children: [
    //                                           Text(item.nombreComercial,
    //                                               style:
    //                                                   TextStyle(fontSize: 10),
    //                                               textAlign: TextAlign.left),
    //                                         ],
    //                                       ),
    //                                       _value2 != null
    //                                           ? Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment
    //                                                       .spaceBetween,
    //                                               children: [
    //                                                 Text(
    //                                                   'Delivery',
    //                                                   style: TextStyle(
    //                                                       fontSize: 12.0,
    //                                                       color:
    //                                                           Color(0xFF57419D),
    //                                                       fontWeight:
    //                                                           FontWeight.bold),
    //                                                 ),
    //                                                 Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment.end,
    //                                                   children: [
    //                                                     Text(
    //                                                       PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
    //                                                       style: TextStyle(
    //                                                           fontSize: 12.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                     Text(
    //                                                       (delivery).toString(),
    //                                                       style: TextStyle(
    //                                                           fontSize: 18.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ],
    //                                             )
    //                                           : _value != null
    //                                               ? Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment
    //                                                           .spaceBetween,
    //                                                   children: [
    //                                                     Text(
    //                                                       'Domicilio',
    //                                                       style: TextStyle(
    //                                                           fontSize: 12.0,
    //                                                           color: Color(
    //                                                               0xFF57419D),
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold),
    //                                                     ),
    //                                                     Row(
    //                                                       mainAxisAlignment:
    //                                                           MainAxisAlignment
    //                                                               .end,
    //                                                       children: [
    //                                                         Text(
    //                                                           PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
    //                                                           style: TextStyle(
    //                                                               fontSize:
    //                                                                   12.0,
    //                                                               color: Color(
    //                                                                   0xFF57419D),
    //                                                               fontWeight:
    //                                                                   FontWeight
    //                                                                       .bold),
    //                                                         ),
    //                                                         Text(
    //                                                           (recojo)
    //                                                               .toString(),
    //                                                           style: TextStyle(
    //                                                               fontSize:
    //                                                                   18.0,
    //                                                               color: Color(
    //                                                                   0xFF57419D),
    //                                                               fontWeight:
    //                                                                   FontWeight
    //                                                                       .bold),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                                   ],
    //                                                 )
    //                                               : Container(),
    //                                       Divider(
    //                                         indent: 20,
    //                                         endIndent: 20,
    //                                         color: Color(0xFF57419D)
    //                                             .withOpacity(0.5),
    //                                       ),
    //                                     ],
    //                                   );
    //                                 });
    //                           }),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             'Petpoints Acreditados',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.end,
    //                             children: [
    //                               Text(
    //                                 (result.transactionAmount).toString(),
    //                                 style: TextStyle(
    //                                     fontSize: 18.0,
    //                                     color: Color(0xFF57419D),
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                       SizedBox(
    //                         height: 8,
    //                       ),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             'Tu cargo',
    //                             style: TextStyle(
    //                                 fontSize: 12.0,
    //                                 color: Color(0xFF57419D),
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.end,
    //                             children: [
    //                               Text(
    //                                 PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
    //                                 style: TextStyle(
    //                                     fontSize: 12.0,
    //                                     color: Color(0xFF57419D),
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                               Text(
    //                                 (result.transactionAmount).toString(),
    //                                 style: TextStyle(
    //                                     fontSize: 18.0,
    //                                     color: Color(0xFF57419D),
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   }
    //   if (result.status != 'approved') {
    //     showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         title: Row(
    //           children: [
    //             Icon(
    //               Icons.cancel,
    //               color: Colors.red,
    //             ),
    //             SizedBox(
    //               width: 10,
    //             ),
    //             Text(
    //               'Su pago ha sido rechazado.',
    //               style: TextStyle(fontSize: 14),
    //             ),
    //           ],
    //         ),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               // Text('This is a demo alert dialog.'),
    //               // Text('Would you like to approve of this message?'),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //
    //     setState(() {
    //       db
    //           .collection('Ordenes')
    //           .doc(productId)
    //           .collection('Items')
    //           .getDocuments()
    //           .then((snapshot) {
    //         for (DocumentSnapshot doc in snapshot.documents) {
    //           doc.reference.delete();
    //         }
    //         ;
    //       });
    //       db.collection('Ordenes').doc(productId).delete();
    //     });
    //   }
    // }
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: MediaQuery.of(context).size.height * .60,
              color:
                  Color(0xFF737373), //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor

              child: Container(
                  width: 60.0,
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
                    children: [
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
                                  PetshopApp.sharedPreferences
                                      .getString(PetshopApp.simboloMoneda),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (widget.serviceModel.precio +
                                          recojo +
                                          delivery)
                                      .toString(),
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
                                    child: Text(
                                        (ppAcumulados - ppCanjeados).toString(),
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
                                    Text(
                                        PetshopApp.sharedPreferences.getString(
                                            PetshopApp.simboloMoneda),
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Color(0xFF57419D),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        (ppvalor * (ppAcumulados - ppCanjeados))
                                            .toStringAsPrecision(3),
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
                                      totalPet = ppvalor *
                                          (ppAcumulados - ppCanjeados);
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
                                  PetshopApp.sharedPreferences
                                      .getString(PetshopApp.simboloMoneda),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (totalPet).toStringAsPrecision(3),
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
                                  PetshopApp.sharedPreferences
                                      .getString(PetshopApp.simboloMoneda),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF57419D),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (widget.serviceModel.precio +
                                          recojo +
                                          delivery -
                                          totalPet)
                                      .toStringAsPrecision(3),
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
                    ],
                  )));
        });
  }
}
