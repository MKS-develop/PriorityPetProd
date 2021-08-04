import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Config/enums.dart';
import 'package:pet_shop/Models/Cart.dart';
import 'package:pet_shop/Models/Promo.dart';
import 'package:pet_shop/Models/alidados.dart';
import 'package:pet_shop/Models/daymodel.dart';
import 'package:pet_shop/Models/especialidades.dart';
import 'package:pet_shop/Models/location.dart';
import 'package:pet_shop/Models/service.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Store/PushNotificationsProvider.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

int cantidad = 1;

double width;

class CitaAgenda extends StatefulWidget {
  final PetModel petModel;
  final ServiceModel serviceModel;
  final AliadoModel aliadoModel;
  final LocationModel locationModel;
  final PromotionModel promotionModel;
  final EspecialidadesModel especialidadesModel;
  final int defaultChoiceIndex;

  CitaAgenda(
      {this.petModel,
      this.promotionModel,
      this.aliadoModel,
      this.locationModel,
      this.serviceModel,
      this.especialidadesModel,
      this.defaultChoiceIndex});

  @override
  _CitaAgendaState createState() => _CitaAgendaState();
}

class _CitaAgendaState extends State<CitaAgenda> {
  final pushProvider = PushNotificationsProvider();
  Timestamp date;
  String hora;
  String fecha = '0';
  int recojo = 0;
  int delivery = 0;
  int _defaultChoiceIndex;
  int _2defaultChoiceIndex;
  bool _value = false;
  bool _value2 = false;
  AliadoModel ali;
  LocationModel location;
  PromotionModel pro;
  ServiceModel servicio;
  DateTime selectedDate = DateTime.now();
  PetModel model;
  CartModel cart;
  bool select = false;
  bool uploading = false;
  String petImageUrl = "";
  String downloadUrl = "";
  bool get wantKeepAlive => true;
  File file;
  BuildContext dialogContext;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  int ppAcumulados = 0;
  int ppCanjeados = 0;
  String tituloCategoria = "Servicio";
  double totalPet = 0;
  dynamic _totalPrice;

  @override
  void initState() {
    changePro(widget.promotionModel);
    changeAli(widget.aliadoModel);
    //initializeDateFormatting("es_VE", null).then((_) {});

    super.initState();
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    var formatter = DateFormat.yMMMEd('es_VE');
    String formatted = formatter.format(DateTime.now());
    print(formatted);
    // DateTime dateTime = DateTime.parse((formatted));
    // print('la fecha es: $dateTime');
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      child: Image.network(
                        widget.aliadoModel.avatar,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              widget.aliadoModel.nombreComercial != null
                                  ? widget.aliadoModel.nombreComercial
                                  : "",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF57419D),
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          Text(
                              widget.locationModel.direccionLocalidad != null
                                  ? widget.locationModel.direccionLocalidad
                                  : "",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.left),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Aliados")
                                  .doc(widget.serviceModel.aliadoId)
                                  .collection("Especialidades")
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (dataSnapshot.hasData) {
                                  if (dataSnapshot.data.docs.length == 0) {
                                    return Center(child: Container());
                                  }
                                }
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
                                      EspecialidadesModel especialidades =
                                          EspecialidadesModel.fromJson(
                                              dataSnapshot.data.docs[index]
                                                  .data());
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.aliadoModel.tipoAliado !=
                                                  'Médico'
                                              ? Text(
                                                  widget.serviceModel.titulo,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : Text(
                                                  especialidades.especialidad !=
                                                          null
                                                      ? especialidades
                                                          .especialidad
                                                      : "",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                          Row(
                                            children: [
                                              Text(
                                                'Certificado: ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                especialidades.certificado !=
                                                        null
                                                    ? especialidades.certificado
                                                    : "",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    });
                              }),
                          SizedBox(
                            height: 5,
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Servicio a domicilio', style: TextStyle(color: Color(0xFF7F9D9D), fontSize: 16),),
                //     Row(
                //       children: [
                //         Text("\$", style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                //         Text((widget.serviceModel.domicilio).toString(), style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                //         Checkbox(value: _value, activeColor: Color(0xFF57419D), onChanged: (bool value){
                //           setState(() {
                //             _value = value;
                //             if(value==true){
                //                recojo = widget.serviceModel.domicilio;
                //                _value2=false;
                //                delivery=0;
                //             }
                //             else{
                //              recojo = 0;
                //             }
                //           });
                //         }
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monto de la consulta ',
                        style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
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
                          (widget.serviceModel.precio).toStringAsFixed(2),
                          style: TextStyle(
                            color: Color(0xFF57419D),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Checkbox(value: _value2, activeColor: Color(0xFF57419D), onChanged: (bool value){
                        //   setState(() {
                        //     _value2 = value;
                        //     if(value==true){
                        //       delivery = widget.serviceModel.delivery;
                        //       _value=false;
                        //       recojo=0;
                        //     }
                        //     else{
                        //       delivery = 0;
                        //     }
                        //   });
                        // }
                        //
                        // ),
                      ],
                    ),
                  ],
                ),
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
                                              // mainAxisSpacing: 0),
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
                PetshopApp.pasarelaDisponible()
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _screenWidth * 0.9,
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
                                                serviceModel:
                                                    widget.serviceModel,
                                                locationModel:
                                                    widget.locationModel,
                                                tituloCategoria:
                                                    tituloCategoria,
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
                              color: Color(0xFF57419D),
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

                          // Row(
                          //   children: [
                          //     Text("\$", style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                          //     Text((widget.serviceModel.precio+recojo+delivery).toString(), style: TextStyle(color: Color(0xFF57419D), fontSize: 22, fontWeight: FontWeight.bold,),),
                          //   ],
                          // ),
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
                        fontSize: 14,
                      ),
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
        width: 90.0,
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

  Future<void> _respuestaPago(String pagoId, String estadoPago, dynamic montoAprobado) async {
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
      "pagoId": pagoId,
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
      "ppGeneradosD": int.parse((petPoints).toString()),
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

  sendEmail(_email, nombreCompleto, orderId, aliadoAvatar) async {
    await http.get(
        Uri.parse('https://us-central1-priority-pet.cloudfunctions.net/sendOrderDuenoEmail?dest=$_email&username=$nombreCompleto&orderId=$orderId&logoAliado=$aliadoAvatar'));
    print('$_email $nombreCompleto $orderId $aliadoAvatar');
  }

// AddOrder(String itemID, BuildContext context) {
//   var databaseReference =
//       FirebaseFirestore.instance.collection('Ordenes').doc(productId);
//
//   databaseReference.collection('Items').doc(itemID).setData({
//     "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
//     "nombreComercial": widget.aliadoModel.nombreComercial,
//     "petthumbnailUrl": widget.petModel.petthumbnailUrl,
//     "titulo": widget.serviceModel.titulo,
//     "oid": productId,
//     "aliadoId": widget.serviceModel.aliadoId,
//     "servicioid": itemID,
//     "hora": hora,
//     "fecha": fecha == null ? fecha : fecha.trim(),
//     "date": date,
//     "precio": int.parse(
//         (widget.serviceModel.precio + recojo + delivery).toString()),
//     "mid": widget.petModel.mid,
//     "nombre": widget.petModel.nombre,
//   });
//   databaseReference.setData({
//     "aliadoId": widget.serviceModel.aliadoId,
//     "oid": productId,
//     "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
//     "precio": int.parse(
//         (widget.serviceModel.precio + recojo + delivery).toString()),
//     "tipoOrden": 'Servicio',
//     'createdOn': DateTime.now(),
//     "status": "Por confirmar",
//     "statusCita": "Por confirmar",
//     "mid": widget.petModel.mid,
//     "fecha": fecha == null ? fecha : fecha.trim(),
//     'ppGeneradosD': int.parse(
//         (widget.serviceModel.precio + recojo + delivery).toString()),
//     "date": date,
//     "user": PetshopApp.sharedPreferences.getString(PetshopApp.userName),
//     "nombreComercial": widget.aliadoModel.nombreComercial,
//   }).
//   then((value) => databaseReference.snapshots().listen(onData));
//
//   // setState(() {
//   //   productId = DateTime
//   //       .now()
//   //       .millisecondsSinceEpoch
//   //       .toString();
//   // });
// }
//
//
//
//
//
//
// void onData(DocumentSnapshot event) async {
//   // if(event.data['status'] == 'pagada') {
//   //   setState(() {
//   //     _loading = false;
//   //     _message = event.data['message'];
//   //   });
//   // }
//   //  setState(() {
//   //    procesando = true;
//   //  });
//   //
//   //  if(procesando == true) {
//   //    showDialog(context: context, child:
//   //    new ChoosePetAlertDialog(message: "Procesando su pago, por favor espere...",)
//   //    );
//   //  }
//   // showDialog(
//   //   context: context,
//   //   barrierDismissible: false,
//   //   builder: (BuildContext context) {
//   //     dialogContext = context;
//   //     return Dialog(
//   //       child: SizedBox(
//   //         height: 100,
//   //         child: new Column(
//   //           children: [
//   //             new SizedBox(height: 30,),
//   //             new CircularProgressIndicator(),
//   //             new SizedBox(height: 10,),
//   //             new Text("Procesando su orden, por favor espere..."),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   },
//   // );
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
//     // var databaseReference = FirebaseFirestore.instance.collection('Nuevo').doc(productId);
//     //
//     // databaseReference.updateData({
//     //  'payment': resul,
//     //
//     // });
//
//     if (result.status == 'approved') {
//       pushProvider.sendNotificaction(widget.serviceModel.aliadoId, productId);
//       var val = []; //blank list for add elements which you want to delete
//       val.add(hora);
//       db
//           .collection("Localidades")
//           .doc(widget.serviceModel.localidadId)
//           .collection("Servicios")
//           .doc(widget.serviceModel.servicioId)
//           .collection("Agenda")
//           .doc(fecha)
//           .updateData({
//         "horasDia": FieldValue.arrayRemove(val),
//         "horasReservadas": FieldValue.arrayUnion(val),
//       });
//
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
//       FirebaseFirestore.instance.collection('Ordenes').doc(productId).updateData(
//           {'preference_id': FieldValue.delete()}).whenComplete(() {});
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
//                                         Container(
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
//                                                         '\$',
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
//                                         _value2 != null
//                                             ? Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     'Delivery',
//                                                     style: TextStyle(
//                                                         fontSize: 12.0,
//                                                         color:
//                                                             Color(0xFF57419D),
//                                                         fontWeight:
//                                                             FontWeight.bold),
//                                                   ),
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.end,
//                                                     children: [
//                                                       Text(
//                                                         PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
//                                                         style: TextStyle(
//                                                             fontSize: 12.0,
//                                                             color: Color(
//                                                                 0xFF57419D),
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       Text(
//                                                         (delivery).toString(),
//                                                         style: TextStyle(
//                                                             fontSize: 18.0,
//                                                             color: Color(
//                                                                 0xFF57419D),
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               )
//                                             : _value != null
//                                                 ? Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                         'Domicilio',
//                                                         style: TextStyle(
//                                                             fontSize: 12.0,
//                                                             color: Color(
//                                                                 0xFF57419D),
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .end,
//                                                         children: [
//                                                           Text(
//                                                             PetshopApp.sharedPreferences.getString(PetshopApp.simboloMoneda),
//                                                             style: TextStyle(
//                                                                 fontSize:
//                                                                     12.0,
//                                                                 color: Color(
//                                                                     0xFF57419D),
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold),
//                                                           ),
//                                                           Text(
//                                                             (recojo)
//                                                                 .toString(),
//                                                             style: TextStyle(
//                                                                 fontSize:
//                                                                     18.0,
//                                                                 color: Color(
//                                                                     0xFF57419D),
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   )
//                                                 : Container(),
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
//                                   '\$ ',
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
}
