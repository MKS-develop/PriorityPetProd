import 'dart:io';

import 'package:age/age.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/expedientechart.dart';
import 'package:pet_shop/Models/temperaturachart.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Widgets/customTextIconField.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../../Widgets/myDrawer.dart';
import 'package:pet_shop/Models/expediente.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/date_symbol_data_local.dart';

double width;

class HistoriaMedica extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  HistoriaMedica({this.petModel, this.defaultChoiceIndex});

  @override
  _HistoriaMedicaState createState() => _HistoriaMedicaState();
}

class _HistoriaMedicaState extends State<HistoriaMedica> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _datePeso = new TextEditingController();
  final TextEditingController _dateTemp = new TextEditingController();
  final TextEditingController _dateEste = new TextEditingController();
  final TextEditingController _dateVacu = new TextEditingController();
  final TextEditingController _dateAler = new TextEditingController();
  final TextEditingController _datePat = new TextEditingController();
  final TextEditingController _textPeso = new TextEditingController();
  final TextEditingController _textTemp = new TextEditingController();
  final TextEditingController _textEste = new TextEditingController();
  final TextEditingController _date2TextEditingController =
      TextEditingController();
  final TextEditingController _dateDesparasitacion =
      new TextEditingController();
  final TextEditingController _lugarNacTextEditingController =
      TextEditingController();
  final TextEditingController _dondeViveTextEditingController =
      TextEditingController();
  final TextEditingController _convivenTextEditingController =
      TextEditingController();
  final TextEditingController _suenoTextEditingController =
      TextEditingController();
  final TextEditingController _castraTextEditingController =
      TextEditingController();
  final TextEditingController _cirugiaTextEditingController =
      TextEditingController();
  final TextEditingController _cirugiaComenTextEditingController =
      TextEditingController();
  final TextEditingController _alimentoMarcaTextEditingController =
      TextEditingController();
  final TextEditingController _alimentoCantidadTextEditingController =
      TextEditingController();
  final TextEditingController _otrosAntecedentesTextEditingController =
      TextEditingController();
  final TextEditingController _dateTextEditingController =
      TextEditingController();

  String _pat = "";
  String _aler = "";
  String _vacu = "";
  String _actividadFisica;
  String _tipoVivienda;
  String _agua;
  String _evacuaciones;
  String _miccion;
  String _intensidadCelos;
  String _tipoAlimentacion;
  String _frecuenciaAlimento;

  bool _value = false;
  bool _value2 = false;
  bool _value3 = false;
  bool _value4 = false;
  bool _value5 = false;
  bool _value6 = false;
  bool _value7 = false;
  bool _value8 = false;
  bool _value9 = false;
  bool _value10 = false;
  bool _castrado;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<charts.Series<ExpedienteChart, String>> _seriesBarData;
  List<ExpedienteChart> mydata;

  _generateData(mydata) {
    _seriesBarData = List<charts.Series<ExpedienteChart, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (ExpedienteChart expe, _) =>
            DateFormat('dd-MM-yyyy').format(expe.fechaPeso.toDate()),
        measureFn: (ExpedienteChart expe, _) => expe.peso,
        fillColorFn: (ExpedienteChart expe, _) =>
            charts.ColorUtil.fromDartColor(Color(0xFF57419D)),
        id: 'ExpedienteChart',
        data: mydata,
      ),
    );
  }

  List<charts.Series<TemperaturaChart, String>> _seriesBarData2;
  List<TemperaturaChart> mydata2;

  _generateData2(mydata2) {
    _seriesBarData2 = List<charts.Series<TemperaturaChart, String>>();
    _seriesBarData2.add(
      charts.Series(
        domainFn: (TemperaturaChart temperaturaChart, _) =>
            DateFormat('dd-MM-yyyy')
                .format(temperaturaChart.fechaTemperatura.toDate()),
        measureFn: (TemperaturaChart temperaturaChart, _) =>
            temperaturaChart.temperatura,
        fillColorFn: (TemperaturaChart temperaturaChart, _) =>
            charts.ColorUtil.fromDartColor(Color(0xFF57419D)),
        id: 'TemperaturaChart',
        data: mydata2,
      ),
    );
  }

  int tab = 1;
  PetModel model;
  ExpedienteModel exp;
  bool select = true;
  bool uploading = false;
  bool peso = false;
  bool temperatura = false;
  bool desparasitacion = false;
  bool vacunas = false;
  bool alergias = false;
  bool patologias = false;
  bool castrado = false;
  bool ambiental = false;
  bool fisiologicos = false;
  bool alimenticios = false;
  bool familiares = false;
  DateTime fecha;

  String petImageUrl = "";
  String downloadUrl = "";

  bool get wantKeepAlive => true;
  File file;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    //initializeDateFormatting("es_VE", null).then((_) {});
    changePet(widget.petModel);
    _pat = " ";
    _aler = " ";
    _vacu = " ";
    getAntecedentes();
  }

  getAntecedentes() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Antecedentes')
        .doc(widget.petModel.mid);
    documentReference.get().then((dataSnapshot) {
      setState(() {
        _actividadFisica = (dataSnapshot["actividadFisica"]);
        _convivenTextEditingController.text =
             (dataSnapshot["convivenciaAnimales"]);
        _dondeViveTextEditingController.text =
             (dataSnapshot["dondeVivido"]);
        _lugarNacTextEditingController.text =
             (dataSnapshot["lugarNacimiento"]);
        _tipoVivienda =  (dataSnapshot["tipoVivienda"]);

        _value =  (dataSnapshot["antePadresValues"]["cancerPadre"]);
        _value2 =  (dataSnapshot["antePadresValues"]["cancerMadre"]);
        _value3 =  (dataSnapshot["antePadresValues"]["diabetesPadre"]);
        _value4 =  (dataSnapshot["antePadresValues"]["diabetesMadre"]);
        _value5 =
             (dataSnapshot["antePadresValues"]["cardiopatiasPadre"]);
        _value6 =
             (dataSnapshot["antePadresValues"]["cardiopatiasMadre"]);
        _value7 =
             (dataSnapshot["antePadresValues"]["aparatoLocomotorPadre"]);
        _value8 =
             (dataSnapshot["antePadresValues"]["aparatoLocomotorMadre"]);
        _value9 =
             (dataSnapshot["antePadresValues"]["sistemaNerviosoPadre"]);
        _value10 =  (dataSnapshot["antePadresValues"]["cancerPadre"]);
        _otrosAntecedentesTextEditingController.text =
             (dataSnapshot["antePadresValues"]["otras"]);

        _agua =  (dataSnapshot["anteFisiologicosValues"]["tomaAgua"]);
        _evacuaciones =
             (dataSnapshot["anteFisiologicosValues"]["defecacion"]);
        _castrado =
             (dataSnapshot["anteFisiologicosValues"]["castracion"]);
        _miccion =  (dataSnapshot["anteFisiologicosValues"]["diuresis"]);
        _suenoTextEditingController.text =
             (dataSnapshot["anteFisiologicosValues"]["sueno"]);

        _intensidadCelos =
             (dataSnapshot["anteFisiologicosValues"]["frecuenciaCelos"]);
        _cirugiaTextEditingController.text =
             (dataSnapshot["anteFisiologicosValues"]["cirugiaEstetica"]);
        _cirugiaComenTextEditingController.text = (dataSnapshot
            ["anteFisiologicosValues"]["comentarioCirugia"]);

        _tipoAlimentacion =
             (dataSnapshot["anteAlimenticioValues"]["cacera"]);
        _alimentoCantidadTextEditingController.text =
             (dataSnapshot["anteAlimenticioValues"]["cantidad"]);
        _frecuenciaAlimento =
             (dataSnapshot["anteAlimenticioValues"]["frecuencia"]);
        _alimentoMarcaTextEditingController.text =
             (dataSnapshot["anteAlimenticioValues"]["marca"]);
        _tipoAlimentacion =
             (dataSnapshot["anteAlimenticioValues"]["tipoAlimenticio"]);
        fecha = DateTime.fromMicrosecondsSinceEpoch(dataSnapshot
            ["anteFisiologicosValues"]["fechaUltimoEstrogeno"]
            .microsecondsSinceEpoch);
      });
      if (_castrado == true) {
        setState(() {
          _castraTextEditingController.value = TextEditingValue(text: 'Sí');
        });
      }
      if (_castrado == false) {
        setState(() {
          _castraTextEditingController.value = TextEditingValue(text: 'No');
        });
      }

      if (fecha != '') {
        var formatter = DateFormat.yMd('es_VE');

        if (fecha != null) {
          String formatted = formatter.format(DateTime.parse(fecha.toString()));
          print(formatted);
          _dateTextEditingController.value = TextEditingValue(text: formatted);

          _date2TextEditingController.value =
              TextEditingValue(text: fecha.toString());
        }
      }
    });
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    DateTime birthday = widget.petModel.fechanac.toDate();
    DateTime today = DateTime.now(); //2020/1/24
    AgeDuration age;
    age = Age.dateDifference(
        fromDate: birthday, toDate: today, includeToDate: false);

    print(age.years);
    print(DateFormat('yyyy-MM-dd').format(widget.petModel.fechanac.toDate()));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        bottomNavigationBar:
            CustomBottomNavigationBar(petModel: widget.petModel),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          // decoration: new BoxDecoration(
          //   image: new DecorationImage(
          //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
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
                        "Expediente médico",
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // FlatButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         tab = 0;
                          //         // select = true;
                          //         peso = false;
                          //         temperatura = false;
                          //         desparasitacion = false;
                          //         vacunas = false;
                          //         alergias = false;
                          //         patologias = false;
                          //         castrado = false;
                          //       });
                          //     },
                          //     minWidth: _screenWidth * 0.19,
                          //     padding: EdgeInsets.all(15.0),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.only(
                          //         topLeft: Radius.circular(10.0),
                          //         topRight: Radius.zero,
                          //         bottomLeft: Radius.circular(10.0),
                          //         bottomRight: Radius.zero,
                          //       ),
                          //     ),
                          //     child: Text(
                          //       'Registro',
                          //       style: TextStyle(
                          //           color: tab == 0
                          //               ? Colors.white
                          //               : Color(0xFF57419D),
                          //           fontSize: 16),
                          //     ),
                          //     color: tab == 0
                          //         ? Color(0xFF57419D)
                          //         : Color(0xFFBDD7D6)),
                          FlatButton(
                              onPressed: () {
                                setState(() {
                                  // select = false;
                                  tab = 1;
                                  peso = false;
                                  temperatura = false;
                                  desparasitacion = false;
                                  vacunas = false;
                                  alergias = false;
                                  patologias = false;
                                  castrado = false;
                                });
                              },
                              minWidth: _screenWidth * 0.4,
                              padding: EdgeInsets.all(15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.zero,
                                ),
                              ),
                              child: Text(
                                'Control',
                                style: TextStyle(
                                    color: tab == 1
                                        ? Colors.white
                                        : Color(0xFF57419D),
                                    fontSize: 16),
                              ),
                              color: tab == 1
                                  ? Color(0xFF57419D)
                                  : Color(0xFFBDD7D6)),
                          FlatButton(
                              onPressed: () {
                                setState(() {
                                  tab = 2;
                                  // select = false;
                                  peso = false;
                                  temperatura = false;
                                  desparasitacion = false;
                                  vacunas = false;
                                  alergias = false;
                                  patologias = false;
                                  castrado = false;
                                });
                              },
                              minWidth: _screenWidth * 0.4,
                              padding: EdgeInsets.all(15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                'Antecedentes',
                                style: TextStyle(
                                    color: tab == 2
                                        ? Colors.white
                                        : Color(0xFF57419D),
                                    fontSize: 16),
                              ),
                              color: tab == 2
                                  ? Color(0xFF57419D)
                                  : Color(0xFFBDD7D6)),
                        ],
                      ),
                    ),
                    // select == true
                    tab == 0
                        ? Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Edad',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            CustomTextField(
                                              isObsecure: false,
                                              keyboard: TextInputType.number,
                                              hintText: age.years.toString(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha de nacimiento',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            CustomTextIconField(
                                              isObsecure: false,
                                              data: Icons.web,
                                              hintText: DateFormat('dd-MM-yyyy')
                                                  .format(widget
                                                      .petModel.fechanac
                                                      .toDate()),
                                              keyboard: TextInputType.datetime,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 30.0),
                                      // Column(
                                      //   children: [
                                      //     uploading ? linearProgress() : Text(""),
                                      //     InkWell(
                                      //       onTap: _selectAndPickImage,
                                      //       child: CircleAvatar(
                                      //         backgroundColor: Color(
                                      //             0xFF7F9D9D),
                                      //         radius: _screenWidth * 0.09,
                                      //         child: CircleAvatar(
                                      //           radius: _screenWidth * 0.085,
                                      //           backgroundColor: Colors.white,
                                      //           backgroundImage: file == null
                                      //               ? null
                                      //               : FileImage(file),
                                      //           child: file == null
                                      //               ? Icon(Icons.add_photo_alternate,
                                      //               size: _screenWidth * 0.08, color:  Color(
                                      //                   0xFF7F9D9D))
                                      //               : null,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //
                                      //
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Peso (Kg)',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            CustomTextField(
                                              isObsecure: false,
                                              keyboard: TextInputType.number,
                                              controller: _textPeso,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDatePeso(context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller: _datePeso,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23,
                                          ),
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  savePesoInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Temperatura (°C)',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            CustomTextField(
                                              isObsecure: false,
                                              keyboard: TextInputType.number,
                                              data: null,
                                              controller: _textTemp,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDateTemp(context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller: _dateTemp,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  saveTempInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                          SizedBox(
                                            height: 6,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.fromLTRB(0, 8, 0, 18),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceEvenly,
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     children: [
                                //       Container(
                                //         width: 130.0,
                                //         child: Column(
                                //           crossAxisAlignment:
                                //               CrossAxisAlignment.start,
                                //           children: [
                                //             Text(
                                //               'Esterilizado/Castrado',
                                //               style: TextStyle(
                                //                   fontSize: 15,
                                //                   color: Color(0xFF1A3E4D)),
                                //             ),
                                //             CustomTextField(
                                //               controller: _textEste,
                                //               isObsecure: false,
                                //               keyboard: TextInputType.text,
                                //               data: null,
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       Container(
                                //         width: 150.0,
                                //         child: Column(
                                //           crossAxisAlignment:
                                //               CrossAxisAlignment.start,
                                //           children: [
                                //             Text(
                                //               'Fecha',
                                //               style: TextStyle(
                                //                   fontSize: 15,
                                //                   color: Color(0xFF1A3E4D)),
                                //             ),
                                //             GestureDetector(
                                //               onTap: () =>
                                //                   _selectDateEste(context),
                                //               child: AbsorbPointer(
                                //                 child: CustomTextIconField(
                                //                   controller: _dateEste,
                                //                   isObsecure: false,
                                //                   data: Icons.web,
                                //                   keyboard:
                                //                       TextInputType.datetime,
                                //                 ),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       Column(
                                //         children: [
                                //           Container(
                                //               width: _screenWidth * 0.15,
                                //               child: RaisedButton(
                                //                 onPressed: () {
                                //                   saveEsteInfo();
                                //                 },
                                //                 shape: RoundedRectangleBorder(
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             10)),
                                //                 color: Color(0xFF57419D),
                                //                 padding: EdgeInsets.all(12.0),
                                //                 child: Center(
                                //                     child: Icon(
                                //                   Icons.save_rounded,
                                //                   color: Colors.white,
                                //                 )),
                                //               )),
                                //           SizedBox(
                                //             height: 6,
                                //           ),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Desparasitación',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDateDesparasitacion(
                                                      context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller:
                                                      _dateDesparasitacion,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23,
                                          ),
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  saveDespaInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Vacunas',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Especies")
                                                  .doc(widget.petModel.especie)
                                                  .collection("Vacunas")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  List<DropdownMenuItem>
                                                      vacunasItems = [];
                                                  for (int i = 0;
                                                      i <
                                                          snapshot.data
                                                              .docs.length;
                                                      i++) {
                                                    DocumentSnapshot snap =
                                                        snapshot
                                                            .data.docs[i];
                                                    vacunasItems.add(
                                                      DropdownMenuItem(
                                                        child: Text(
                                                          snap.id,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        value:
                                                            "${snap.id}",
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF7f9d9D),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    margin: EdgeInsets.all(5.0),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          disabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                        ),
                                                        items: vacunasItems,
                                                        icon: Icon(
                                                          // Add this
                                                          Icons
                                                              .add_box, // Add this
                                                          // Add this
                                                        ),
                                                        isExpanded: true,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _vacu = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDateVacu(context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller: _dateVacu,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23,
                                          ),
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  saveVacunaInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Alergias',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Especies")
                                                  .doc(widget.petModel.especie)
                                                  .collection("Alergias")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  List<DropdownMenuItem>
                                                      alergiasItems = [];
                                                  for (int i = 0; i < snapshot.data.docs.length; i++) {
                                                    DocumentSnapshot snap = snapshot.data.docs[i];
                                                    alergiasItems.add(
                                                      DropdownMenuItem(
                                                        child: Text(
                                                          snap.id,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        value:
                                                            "${snap.id}",
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF7f9d9D),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    margin: EdgeInsets.all(5.0),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          disabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                        ),
                                                        items: alergiasItems,
                                                        icon: Icon(
                                                          // Add this
                                                          Icons
                                                              .add_box, // Add this
                                                          // Add this
                                                        ),
                                                        isExpanded: true,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _aler = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDateAler(context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller: _dateAler,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23,
                                          ),
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  saveAlergiaInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Patología',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Especies")
                                                  .doc(widget.petModel.especie)
                                                  .collection("Patologias")
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else {
                                                  List<DropdownMenuItem>
                                                      patologiasItems = [];
                                                  for (int i = 0;
                                                      i <
                                                          snapshot.data
                                                              .docs.length;
                                                      i++) {
                                                    DocumentSnapshot snap =
                                                        snapshot
                                                            .data.docs[i];
                                                    patologiasItems.add(
                                                      DropdownMenuItem(
                                                        child: Text(
                                                          snap.id,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        value:
                                                            "${snap.id}",
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF7f9d9D),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    margin: EdgeInsets.all(5.0),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField(
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          disabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                        ),
                                                        items: patologiasItems,
                                                        icon: Icon(
                                                          Icons.add_box,
                                                        ),
                                                        isExpanded: true,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _pat = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 150.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fecha',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF1A3E4D)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _selectDatePat(context),
                                              child: AbsorbPointer(
                                                child: CustomTextIconField(
                                                  controller: _datePat,
                                                  isObsecure: false,
                                                  data: Icons.web,
                                                  keyboard:
                                                      TextInputType.datetime,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 23,
                                          ),
                                          Container(
                                              width: _screenWidth * 0.15,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  savePatoInfo();
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Color(0xFF57419D),
                                                padding: EdgeInsets.all(12.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                )),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Center(
                                //   child: Container(
                                //       width: _screenWidth*0.84,
                                //
                                //       child: RaisedButton(onPressed: () {
                                //         uploadImageAndSavePetInfo();
                                //
                                //       },
                                //         shape: RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(10)),
                                //         color: Color(0xFF57419D),
                                //         padding: EdgeInsets.all(15.0),
                                //         child:
                                //         Text("Guardar", style: TextStyle(
                                //             fontFamily: 'Product Sans',
                                //             color: Colors.white,
                                //             fontSize: 25.0)),
                                //
                                //       )
                                //   ),
                                // )
                              ],
                            ),
                          )
                        : Container(),

                    tab == 1
                        ? Column(children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    String tituloDetalle = "Peso (Kg)";

                                    if (peso == false) {
                                      setState(() {
                                        peso = true;
                                      });
                                    } else {
                                      setState(() {
                                        peso = false;
                                      });
                                    }

                                    // Navigator.push(
                                    //   context,
                                    //
                                    //   MaterialPageRoute(builder: (context) => PesoDetalle(petModel: model, tituloDetalle: tituloDetalle,)),
                                    // );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/peso.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Peso",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      peso == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  peso = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  peso = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            peso == true
                                ? Column(
                                    children: [
                                      Container(
                                        height: 200,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Expedientes')
                                              .doc(widget.petModel.mid)
                                              .collection('Peso')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return LinearProgressIndicator();
                                            } else {
                                              List<ExpedienteChart> expediente =
                                                  snapshot.data.docs
                                                      .map((documentSnapshot) =>
                                                          ExpedienteChart.fromMap(
                                                              documentSnapshot
                                                                  .data()))
                                                      .toList();

                                              return _buildChart(
                                                  context, expediente);
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 130.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Peso (Kg)',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF1A3E4D)),
                                                  ),
                                                  CustomTextField(
                                                    isObsecure: false,
                                                    keyboard:
                                                        TextInputType.number,
                                                    controller: _textPeso,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 150.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Fecha',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF1A3E4D)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _selectDatePeso(
                                                            context),
                                                    child: AbsorbPointer(
                                                      child:
                                                          CustomTextIconField(
                                                        controller: _datePeso,
                                                        isObsecure: false,
                                                        data: Icons.web,
                                                        keyboard: TextInputType
                                                            .datetime,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height: 23,
                                                ),
                                                Container(
                                                    width: _screenWidth * 0.15,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        savePesoInfo();
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          80)),
                                                      color: Color(0xFF57419D),
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: Center(
                                                          child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      )),
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    String tituloDetalle = "Temperatura (°C)";
                                    // Navigator.push(
                                    //   context,
                                    //
                                    //   MaterialPageRoute(builder: (context) => TempDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                    // );

                                    if (temperatura == false) {
                                      setState(() {
                                        temperatura = true;
                                      });
                                    } else {
                                      setState(() {
                                        temperatura = false;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/temperatura.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Temperatura",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      temperatura == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  temperatura = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  temperatura = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            temperatura == true
                                ? Column(
                                    children: [
                                      Container(
                                        height: 200,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Expedientes')
                                              .doc(widget.petModel.mid)
                                              .collection('Temperatura')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return LinearProgressIndicator();
                                            } else {
                                              List<TemperaturaChart>
                                                  temperaturachart = snapshot
                                                      .data.docs
                                                      .map((documentSnapshot) =>
                                                          TemperaturaChart
                                                              .fromMap(
                                                                  documentSnapshot
                                                                      .data()))
                                                      .toList();

                                              return _buildChart2(
                                                  context, temperaturachart);
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 130.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Temperatura (°C)',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF1A3E4D)),
                                                  ),
                                                  CustomTextField(
                                                    isObsecure: false,
                                                    keyboard:
                                                        TextInputType.number,
                                                    data: null,
                                                    controller: _textTemp,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 150.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Fecha',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF1A3E4D)),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _selectDateTemp(
                                                            context),
                                                    child: AbsorbPointer(
                                                      child:
                                                          CustomTextIconField(
                                                        controller: _dateTemp,
                                                        isObsecure: false,
                                                        data: Icons.web,
                                                        keyboard: TextInputType
                                                            .datetime,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    width: _screenWidth * 0.15,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        saveTempInfo();
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          80)),
                                                      color: Color(0xFF57419D),
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: Center(
                                                          child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      )),
                                                    )),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    String tituloDetalle = "Desparasitación";

                                    if (desparasitacion == false) {
                                      setState(() {
                                        desparasitacion = true;
                                      });
                                    } else {
                                      setState(() {
                                        desparasitacion = false;
                                      });
                                    }
                                    // Navigator.push(
                                    //   context,
                                    //
                                    //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                    // );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/despa.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Desparasitación",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      desparasitacion == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  desparasitacion = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  desparasitacion = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            desparasitacion == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Fecha',
                                          style: TextStyle(
                                              color: Color(0xFF57419D),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                            stream: db
                                                .collection("Expedientes")
                                                .doc(widget.petModel.mid)
                                                .collection("Desparasitacion")
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: dataSnapshot
                                                      .data.docs.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    ExpedienteModel exp =
                                                        ExpedienteModel
                                                            .fromJson(
                                                                dataSnapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data());
                                                    return Column(
                                                      children: [
                                                        Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(exp
                                                                    .fechaDesparasitacion
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                    0xFF7F9D9D))),
                                                      ],
                                                    );
                                                  });
                                            }),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 8, 0, 18),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 130.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Desparasitación',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 150.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Fecha',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _selectDateDesparasitacion(
                                                              context),
                                                      child: AbsorbPointer(
                                                        child:
                                                            CustomTextIconField(
                                                          controller:
                                                              _dateDesparasitacion,
                                                          isObsecure: false,
                                                          data: Icons.web,
                                                          keyboard:
                                                              TextInputType
                                                                  .datetime,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 23,
                                                  ),
                                                  Container(
                                                      width:
                                                          _screenWidth * 0.15,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          saveDespaInfo();
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        color:
                                                            Color(0xFF57419D),
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        )),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    String tituloDetalle = "Vacunas";

                                    if (vacunas == false) {
                                      setState(() {
                                        vacunas = true;
                                      });
                                    } else {
                                      setState(() {
                                        vacunas = false;
                                      });
                                    }
                                    // Navigator.push(
                                    //   context,
                                    //
                                    //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                    // );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/vacunas.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Vacunas",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      vacunas == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  vacunas = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  vacunas = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            vacunas == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        StreamBuilder<QuerySnapshot>(
                                            stream: db
                                                .collection("Expedientes")
                                                .doc(widget.petModel.mid)
                                                .collection("Vacunas")
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: dataSnapshot
                                                      .data.docs.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    ExpedienteModel exp =
                                                        ExpedienteModel
                                                            .fromJson(
                                                                dataSnapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data());
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          exp.vacuna,
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Color(
                                                                  0xFF7F9D9D),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(exp
                                                                    .fechaVacuna
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                    0xFF7F9D9D))),
                                                      ],
                                                    );
                                                  });
                                            }),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 18),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 130.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Vacunas',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    StreamBuilder<
                                                        QuerySnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "Especies")
                                                          .doc(widget
                                                              .petModel.especie)
                                                          .collection("Vacunas")
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        } else {
                                                          List<DropdownMenuItem>
                                                              vacunasItems = [];
                                                          for (int i = 0;
                                                              i <
                                                                  snapshot
                                                                      .data
                                                                      .docs
                                                                      .length;
                                                              i++) {
                                                            DocumentSnapshot
                                                                snap = snapshot
                                                                    .data
                                                                    .docs[i];
                                                            vacunasItems.add(
                                                              DropdownMenuItem(
                                                                child: Text(
                                                                  snap.id,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                value:
                                                                    "${snap.id}",
                                                              ),
                                                            );
                                                          }
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFF7f9d9D),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButtonFormField(
                                                                decoration:
                                                                    InputDecoration(
                                                                  enabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  focusedBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  disabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                ),
                                                                items:
                                                                    vacunasItems,
                                                                icon: Icon(
                                                                  // Add this
                                                                  Icons
                                                                      .add_box, // Add this
                                                                  // Add this
                                                                ),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _vacu =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 150.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Fecha',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _selectDateVacu(
                                                              context),
                                                      child: AbsorbPointer(
                                                        child:
                                                            CustomTextIconField(
                                                          controller: _dateVacu,
                                                          isObsecure: false,
                                                          data: Icons.web,
                                                          keyboard:
                                                              TextInputType
                                                                  .datetime,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 23,
                                                  ),
                                                  Container(
                                                      width:
                                                          _screenWidth * 0.15,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          saveVacunaInfo();
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        color:
                                                            Color(0xFF57419D),
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        )),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (alergias == false) {
                                      setState(() {
                                        alergias = true;
                                      });
                                    } else {
                                      setState(() {
                                        alergias = false;
                                      });
                                    }
                                    String tituloDetalle = "Alergias";
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                    // );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/alergia.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Alergias",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      alergias == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  alergias = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  alergias = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            alergias == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        StreamBuilder<QuerySnapshot>(
                                            stream: db
                                                .collection("Expedientes")
                                                .doc(widget.petModel.mid)
                                                .collection("Alergias")
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: dataSnapshot
                                                      .data.docs.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    ExpedienteModel exp =
                                                        ExpedienteModel
                                                            .fromJson(
                                                                dataSnapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data());
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          exp.alergia,
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Color(
                                                                  0xFF7F9D9D),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(exp
                                                                    .fechaAlergia
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                    0xFF7F9D9D))),
                                                      ],
                                                    );
                                                  });
                                            }),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 18),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 130.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Alergias',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    StreamBuilder<
                                                        QuerySnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "Especies")
                                                          .doc(widget
                                                              .petModel.especie)
                                                          .collection(
                                                              "Alergias")
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        } else {
                                                          List<DropdownMenuItem>
                                                              alergiasItems =
                                                              [];
                                                          for (int i = 0;
                                                              i <
                                                                  snapshot
                                                                      .data
                                                                      .docs
                                                                      .length;
                                                              i++) {
                                                            DocumentSnapshot
                                                                snap = snapshot
                                                                    .data
                                                                    .docs[i];
                                                            alergiasItems.add(
                                                              DropdownMenuItem(
                                                                child: Text(
                                                                  snap.id,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                value:
                                                                    "${snap.id}",
                                                              ),
                                                            );
                                                          }
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFF7f9d9D),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButtonFormField(
                                                                decoration:
                                                                    InputDecoration(
                                                                  enabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  focusedBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  disabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                ),
                                                                items:
                                                                    alergiasItems,
                                                                icon: Icon(
                                                                  // Add this
                                                                  Icons
                                                                      .add_box, // Add this
                                                                  // Add this
                                                                ),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _aler =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 150.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Fecha',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _selectDateAler(
                                                              context),
                                                      child: AbsorbPointer(
                                                        child:
                                                            CustomTextIconField(
                                                          controller: _dateAler,
                                                          isObsecure: false,
                                                          data: Icons.web,
                                                          keyboard:
                                                              TextInputType
                                                                  .datetime,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 23,
                                                  ),
                                                  Container(
                                                      width:
                                                          _screenWidth * 0.15,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          saveAlergiaInfo();
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        color:
                                                            Color(0xFF57419D),
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        )),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    String tituloDetalle = "Patologías";

                                    if (patologias == false) {
                                      setState(() {
                                        patologias = true;
                                      });
                                    } else {
                                      setState(() {
                                        patologias = false;
                                      });
                                    }
                                    // Navigator.push(
                                    //   context,
                                    //
                                    //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                                    // );
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/pato.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Patologías",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      patologias == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  patologias = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  patologias = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            patologias == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        StreamBuilder<QuerySnapshot>(
                                            stream: db
                                                .collection("Expedientes")
                                                .doc(widget.petModel.mid)
                                                .collection("Patologias")
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: dataSnapshot
                                                      .data.docs.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    ExpedienteModel exp =
                                                        ExpedienteModel
                                                            .fromJson(
                                                                dataSnapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data());
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          exp.patologia,
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Color(
                                                                  0xFF7F9D9D),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(exp
                                                                    .fechaPatologia
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                    0xFF7F9D9D))),
                                                      ],
                                                    );
                                                  });
                                            }),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 40),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 130.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Patología',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    StreamBuilder<
                                                        QuerySnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "Especies")
                                                          .doc(widget
                                                              .petModel.especie)
                                                          .collection(
                                                              "Patologias")
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        } else {
                                                          List<DropdownMenuItem>
                                                              patologiasItems =
                                                              [];
                                                          for (int i = 0;
                                                              i <
                                                                  snapshot
                                                                      .data
                                                                      .docs
                                                                      .length;
                                                              i++) {
                                                            DocumentSnapshot
                                                                snap = snapshot
                                                                    .data
                                                                    .docs[i];
                                                            patologiasItems.add(
                                                              DropdownMenuItem(
                                                                child: Text(
                                                                  snap.id,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                value:
                                                                    "${snap.id}",
                                                              ),
                                                            );
                                                          }
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFF7f9d9D),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButtonFormField(
                                                                decoration:
                                                                    InputDecoration(
                                                                  enabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  focusedBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                  disabledBorder:
                                                                      UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide.none),
                                                                ),
                                                                items:
                                                                    patologiasItems,
                                                                icon: Icon(
                                                                  Icons.add_box,
                                                                ),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _pat =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 150.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Fecha',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF1A3E4D)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _selectDatePat(
                                                              context),
                                                      child: AbsorbPointer(
                                                        child:
                                                            CustomTextIconField(
                                                          controller: _datePat,
                                                          isObsecure: false,
                                                          data: Icons.web,
                                                          keyboard:
                                                              TextInputType
                                                                  .datetime,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 23,
                                                  ),
                                                  Container(
                                                      width:
                                                          _screenWidth * 0.15,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          savePatoInfo();
                                                        },
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        color:
                                                            Color(0xFF57419D),
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        )),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            // Padding(
                            //   padding: const EdgeInsets.all(10.0),
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     child: RaisedButton(
                            //       onPressed: () {
                            //         String tituloDetalle =
                            //             "Esterilizado/Castrado";
                            //         // Navigator.push(
                            //         //   context,
                            //         //
                            //         //   MaterialPageRoute(builder: (context) => ConsultaDetalle(petModel: model, tituloDetalle: tituloDetalle)),
                            //         // );
                            //         if (castrado == false) {
                            //           setState(() {
                            //             castrado = true;
                            //           });
                            //         } else {
                            //           setState(() {
                            //             castrado = false;
                            //           });
                            //         }
                            //       },
                            //       shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(10)),
                            //       color: Color(0xFF57419D),
                            //       padding: EdgeInsets.all(10.0),
                            //       child: Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Row(
                            //             children: [
                            //               Image.asset(
                            //                   'diseñador/drawable/Salud/castrado.png'),
                            //               SizedBox(
                            //                 width: 15.0,
                            //               ),
                            //               Column(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.start,
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   Text("Esterilizado/Castrado",
                            //                       style: TextStyle(
                            //                           fontFamily:
                            //                               'Product Sans',
                            //                           color: Colors.white,
                            //                           fontWeight:
                            //                               FontWeight.bold,
                            //                           fontSize: 18.0)),
                            //                 ],
                            //               ),
                            //             ],
                            //           ),
                            //           castrado == false
                            //               ? IconButton(
                            //                   icon: Icon(Icons.add,
                            //                       color: Colors.white),
                            //                   onPressed: () {
                            //                     setState(() {
                            //                       castrado = true;
                            //                     });
                            //                   })
                            //               : IconButton(
                            //                   icon: Icon(Icons.remove_rounded,
                            //                       color: Colors.white),
                            //                   onPressed: () {
                            //                     setState(() {
                            //                       castrado = false;
                            //                     });
                            //                   }),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            castrado == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        StreamBuilder<QuerySnapshot>(
                                            stream: db
                                                .collection("Expedientes")
                                                .doc(widget.petModel.mid)
                                                .collection("Esterilizacion")
                                                .snapshots(),
                                            builder: (context, dataSnapshot) {
                                              if (!dataSnapshot.hasData) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: dataSnapshot
                                                      .data.docs.length,
                                                  shrinkWrap: true,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    ExpedienteModel exp =
                                                        ExpedienteModel
                                                            .fromJson(
                                                                dataSnapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data());
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          exp.esteril,
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Color(
                                                                  0xFF7F9D9D),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(exp
                                                                    .fechaEsteril
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: Color(
                                                                    0xFF7F9D9D))),
                                                      ],
                                                    );
                                                  });
                                            }),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ])
                        : Container(),

                    if (tab == 2)
                      Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (ambiental == false) {
                                      setState(() {
                                        ambiental = true;
                                      });
                                    } else {
                                      setState(() {
                                        ambiental = false;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/despa.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Ambiental",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ambiental == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  ambiental = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  ambiental = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ambiental == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Lugar de nacimiento',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _lugarNacTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText: "Lugar de nacimiento",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Donde ha vivido',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _dondeViveTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText: "Donde ha vivido",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Tipo de vivienda',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: _screenWidth * 0.9,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF7f9d9D),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      margin:
                                                          EdgeInsets.all(5.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: Stack(
                                                          children: <Widget>[
                                                            DropdownButton(
                                                                hint: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          15,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                      'Tipo de vivienda',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Color(0xFF7f9d9D))),
                                                                ),
                                                                items: <String>[
                                                                  'Callejero',
                                                                  'Campo',
                                                                  'Departamento',
                                                                  'Casa',
                                                                  'Otro'
                                                                ].map((String
                                                                    value) {
                                                                  return new DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      child: new Text(
                                                                          value),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _tipoVivienda =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    _tipoVivienda),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Convivencia con otros animales',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _convivenTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText:
                                                  "Convivencia con otros animales",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Actividad física',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: _screenWidth * 0.9,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF7f9d9D),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      margin:
                                                          EdgeInsets.all(5.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: Stack(
                                                          children: <Widget>[
                                                            DropdownButton(
                                                                hint: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          15,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                      'Actividad física',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Color(0xFF7f9d9D))),
                                                                ),
                                                                items: <String>[
                                                                  'Sedentario',
                                                                  'Paseos',
                                                                  'Deportivo',
                                                                  'Entrenamiento'
                                                                ].map((String
                                                                    value) {
                                                                  return new DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      child: new Text(
                                                                          value),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _actividadFisica =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    _actividadFisica),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (familiares == false) {
                                      setState(() {
                                        familiares = true;
                                      });
                                    } else {
                                      setState(() {
                                        familiares = false;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/despa.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Antecedentes familiares",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      familiares == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  familiares = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  familiares = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            familiares == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 14,
                                                  ),
                                                  Text('Cancer',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Padre',
                                                  style: TextStyle(
                                                      color: Color(0xFF57419D),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Checkbox(
                                                    value: _value,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value = value;
                                                        // if (value == true) {
                                                        //   _value = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'Madre',
                                                  style: TextStyle(
                                                      color: Color(0xFF57419D),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Checkbox(
                                                    value: _value2,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value2 = value;
                                                        // if (value == true) {
                                                        //   _value2 = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Diabetes',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value3,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value3 = value;
                                                        // if (value == true) {
                                                        //   _value = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value4,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value4 = value;
                                                        // if (value == true) {
                                                        //   _value2 = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Cardiopatías',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value5,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value5 = value;
                                                        // if (value == true) {
                                                        //   _value = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value6,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value6 = value;
                                                        // if (value == true) {
                                                        //   _value2 = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Aparato Locomotor',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value7,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value7 = value;
                                                        // if (value == true) {
                                                        //   _value = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value8,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value8 = value;
                                                        // if (value == true) {
                                                        //   _value2 = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Sistema Nervioso',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value9,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value9 = value;
                                                        // if (value == true) {
                                                        //   _value = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Checkbox(
                                                    value: _value10,
                                                    activeColor:
                                                        Color(0xFF57419D),
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _value10 = value;
                                                        // if (value == true) {
                                                        //   _value2 = false;
                                                        // } else {}
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Otras',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _otrosAntecedentesTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText: "Otras",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (fisiologicos == false) {
                                      setState(() {
                                        fisiologicos = true;
                                      });
                                    } else {
                                      setState(() {
                                        fisiologicos = false;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/despa.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Fisiológicos",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      fisiologicos == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  fisiologicos = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  fisiologicos = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (fisiologicos == true)
                              Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Toma de agua (Cantidad)',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _screenWidth * 0.9,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Color(0xFF7f9d9D),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  padding: EdgeInsets.all(0.0),
                                                  margin: EdgeInsets.all(5.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: Stack(
                                                      children: <Widget>[
                                                        DropdownButton(
                                                            hint: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      15,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                  'Toma de agua (Cantidad)',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Color(
                                                                          0xFF7f9d9D))),
                                                            ),
                                                            items: <String>[
                                                              '1/2 litro',
                                                              '1 litro',
                                                              '2 litros',
                                                              '3 litros'
                                                            ].map(
                                                                (String value) {
                                                              return new DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      new Text(
                                                                          value),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            isExpanded: true,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _agua = value;
                                                              });
                                                            },
                                                            value: _agua),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Evacuaciones',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _screenWidth * 0.9,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Color(0xFF7f9d9D),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  padding: EdgeInsets.all(0.0),
                                                  margin: EdgeInsets.all(5.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: Stack(
                                                      children: <Widget>[
                                                        DropdownButton(
                                                            hint: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      15,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                  'Evacuaciones',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Color(
                                                                          0xFF7f9d9D))),
                                                            ),
                                                            items: <String>[
                                                              '1 vez',
                                                              '2 veces',
                                                              '3 veces',
                                                              '4 veces',
                                                              '5 veces',
                                                              '6 veces',
                                                              'Más'
                                                            ].map(
                                                                (String value) {
                                                              return new DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      new Text(
                                                                          value),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            isExpanded: true,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _evacuaciones =
                                                                    value;
                                                              });
                                                            },
                                                            value:
                                                                _evacuaciones),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Micción',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _screenWidth * 0.9,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Color(0xFF7f9d9D),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  padding: EdgeInsets.all(0.0),
                                                  margin: EdgeInsets.all(5.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: Stack(
                                                      children: <Widget>[
                                                        DropdownButton(
                                                            hint: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      15,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                  'Micción',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Color(
                                                                          0xFF7f9d9D))),
                                                            ),
                                                            items: <String>[
                                                              '1 vez',
                                                              '2 veces',
                                                              '3 veces',
                                                              '4 veces',
                                                              '5 veces',
                                                              '6 veces',
                                                              'Más'
                                                            ].map(
                                                                (String value) {
                                                              return new DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      new Text(
                                                                          value),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            isExpanded: true,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _miccion =
                                                                    value;
                                                              });
                                                            },
                                                            value: _miccion),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Sueño (Cantidad de horas)',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: _screenWidth * 0.89,
                                        child: CustomTextField(
                                          controller:
                                              _suenoTextEditingController,
                                          keyboard: TextInputType.number,
                                          hintText: "Sueño (Cantidad de horas)",
                                          isObsecure: false,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Fecha de último estro o celo',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          _selectDate(context);
                                        },
                                        child: AbsorbPointer(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _dateTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText:
                                                  "Fecha de último estro o celo",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Frecuencia en intensidad de celos',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _screenWidth * 0.9,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Color(0xFF7f9d9D),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  padding: EdgeInsets.all(0.0),
                                                  margin: EdgeInsets.all(5.0),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: Stack(
                                                      children: <Widget>[
                                                        DropdownButton(
                                                            hint: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      15,
                                                                      0,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                  'Frecuencia en intensidad de celos',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                      color: Color(
                                                                          0xFF7f9d9D))),
                                                            ),
                                                            items: <String>[
                                                              'Poco',
                                                              'Normal',
                                                              'Mucho',
                                                            ].map(
                                                                (String value) {
                                                              return new DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      new Text(
                                                                          value),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            isExpanded: true,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                _intensidadCelos =
                                                                    value;
                                                              });
                                                            },
                                                            value:
                                                                _intensidadCelos),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Castración/Esterilización',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_castrado == false) {
                                            setState(() {
                                              _castraTextEditingController
                                                      .value =
                                                  TextEditingValue(text: 'Sí');
                                              _castrado = true;
                                            });
                                          } else {
                                            _castraTextEditingController.value =
                                                TextEditingValue(text: 'No');
                                            _castrado = false;
                                          }
                                          ;
                                        },
                                        child: AbsorbPointer(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _castraTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText:
                                                  "Castración/Esterilización",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Cirugía estética',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: _screenWidth * 0.89,
                                        child: CustomTextField(
                                          controller:
                                              _cirugiaTextEditingController,
                                          keyboard: TextInputType.text,
                                          hintText: "Cirugía estética",
                                          isObsecure: false,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Comentarios de cirugía estética',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF7F9D9D)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: _screenWidth * 0.89,
                                        child: CustomTextField(
                                          controller:
                                              _cirugiaComenTextEditingController,
                                          keyboard: TextInputType.text,
                                          hintText:
                                              "Comentarios de cirugía estética",
                                          isObsecure: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (alimenticios == false) {
                                      setState(() {
                                        alimenticios = true;
                                      });
                                    } else {
                                      setState(() {
                                        alimenticios = false;
                                      });
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: Color(0xFF57419D),
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                              'diseñador/drawable/Salud/despa.png'),
                                          SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Alimenticio",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      alimenticios == false
                                          ? IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  alimenticios = true;
                                                });
                                              })
                                          : IconButton(
                                              icon: Icon(Icons.remove_rounded,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  alimenticios = false;
                                                });
                                              }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            alimenticios == true
                                ? Container(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Tipo de alimentación',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: _screenWidth * 0.9,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF7f9d9D),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      margin:
                                                          EdgeInsets.all(5.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: Stack(
                                                          children: <Widget>[
                                                            DropdownButton(
                                                                hint: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          15,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                      'Tipo de alimentación',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Color(0xFF7f9d9D))),
                                                                ),
                                                                items: <String>[
                                                                  'Barf',
                                                                  'Concentrados',
                                                                  'Seco y húmedo',
                                                                  'Casera',
                                                                ].map((String
                                                                    value) {
                                                                  return new DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      child: new Text(
                                                                          value),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                                isExpanded:
                                                                    true,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    _tipoAlimentacion =
                                                                        value;
                                                                  });
                                                                },
                                                                value:
                                                                    _tipoAlimentacion),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Marca y tipo de alimento',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: _screenWidth * 0.89,
                                            child: CustomTextField(
                                              controller:
                                                  _alimentoMarcaTextEditingController,
                                              keyboard: TextInputType.text,
                                              hintText:
                                                  "Marca y tipo de alimento",
                                              isObsecure: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  'Cantidad (gr) y frecuencia diaria',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF7F9D9D)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: _screenWidth * 0.65,
                                                child: CustomTextField(
                                                  controller:
                                                      _alimentoCantidadTextEditingController,
                                                  keyboard: TextInputType.text,
                                                  hintText:
                                                      "Cantidad (gr) y frecuencia diaria",
                                                  isObsecure: false,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:
                                                          _screenWidth * 0.24,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFF7f9d9D),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0.0),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child: Stack(
                                                                children: <
                                                                    Widget>[
                                                                  DropdownButton(
                                                                      hint:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            15,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child: Text(
                                                                            '1 vez',
                                                                            style:
                                                                                TextStyle(fontSize: 15.0, color: Color(0xFF7f9d9D))),
                                                                      ),
                                                                      items: <
                                                                          String>[
                                                                        '1 vez',
                                                                        '2 veces',
                                                                        '3 veces',
                                                                        '4 veces',
                                                                        '5 veces',
                                                                        '6 veces',
                                                                        'Más'
                                                                      ].map((String
                                                                          value) {
                                                                        return new DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                10,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                new Text(value),
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                      isExpanded:
                                                                          true,
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          _frecuenciaAlimento =
                                                                              value;
                                                                        });
                                                                      },
                                                                      value:
                                                                          _frecuenciaAlimento),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            ambiental == true ||
                                    fisiologicos == true ||
                                    alimenticios == true ||
                                    familiares == true
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: RaisedButton(
                                        onPressed: () {
                                          saveAntececedentesInfo();
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        color: Color(0xFFEB9448),
                                        padding: EdgeInsets.all(14.0),
                                        child: Text("Actualizar antecedentes",
                                            style: TextStyle(
                                                fontFamily: 'Product Sans',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0)),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    else
                      Container(),
                  ],
                ),
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

  Future<void> _selectAndPickImage() async {
    // File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    //
    // setState(() {
    //   file = imageFile;
    // });
  }

  uploadImageAndSavePetInfo() async {
    setState(() {
      uploading = true;
    });

    savePetInfo();
  }

  // Future<String> uploadPetImage(mFileImage) async {
  //   final Reference reference =
  //       FirebaseStorage.instance.ref().child("Expedientes");
  //   UploadTask uploadTask =
  //       reference.child("expediente_$productId.jpg").putFile(mFileImage);

  //   TaskSnapshot taskSnapshot = await uploadTask.onComplete;

  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();

  //   return downloadUrl;
  // }
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1940, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        var formatter = DateFormat.yMd('es_VE');
        String newtime = formatter.format(picked).toString();
        String timeString = picked.toString();
        _dateTextEditingController.value = TextEditingValue(text: newtime);
        _date2TextEditingController.value =
            TextEditingValue(text: timeString.split(" ")[0]);
        print(_date2TextEditingController.text);
      });
  }

  savePetInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection('Expedientes').doc(widget.petModel.mid).set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "historiathumbnailUrl": downloadUrl,
    });

    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();

      Route route =
          MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
      Navigator.pushReplacement(context, route);
    });
  }

  saveAntececedentesInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Antecedentes')
        .doc(widget.petModel.mid)
        .set({
      "actividadFisica": _actividadFisica,
      "convivenciaAnimales": _convivenTextEditingController.text.trim(),
      "dondeVivido": _dondeViveTextEditingController.text.trim(),
      "lugarNacimiento": _lugarNacTextEditingController.text.trim(),
      "tipoVivienda": _tipoVivienda,
      'createdOn': DateTime.now(),

      "antePadresValues": {
        "cancerPadre": _value,
        "cancerMadre": _value2,
        "diabetesPadre": _value3,
        "diabetesMadre": _value4,
        "cardiopatiasPadre": _value5,
        "cardiopatiasMadre": _value6,
        "aparatoLocomotorPadre": _value7,
        "aparatoLocomotorMadre": _value8,
        "sistemaNerviosoPadre": _value9,
        "sistemaNerviosoMadre": _value10,
        "otras": _otrosAntecedentesTextEditingController.text.trim(),
      },
      "anteFisiologicosValues": {
        "tomaAgua": _agua,
        "defecacion": _evacuaciones,
        "diuresis": _miccion,
        "sueno": _suenoTextEditingController.text.trim(),
        "castracion": _castrado,

        "fechaUltimoEstrogeno": _dateTextEditingController.text == ''
            ? ''
            : DateTime.parse(_date2TextEditingController.text),
        "frecuenciaCelos": _intensidadCelos,

        // "castracion": _value8,

        "cirugiaEstetica": _cirugiaTextEditingController.text.trim(),
        "comentarioCirugia": _cirugiaComenTextEditingController.text.trim(),
      },
      "anteAlimenticioValues": {
        "cacera": _tipoAlimentacion,
        "cantidad": _alimentoCantidadTextEditingController.text.trim(),
        "frecuencia": _frecuenciaAlimento,
        "marca": _alimentoMarcaTextEditingController.text.trim(),
        "tipoAlimenticio": _tipoAlimentacion,
        // "tipoAlimento": _tipoAlimentacion,
      },

      // "mid": widget.petModel.mid,
      // "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      // "eid": productId,
      // "historiathumbnailUrl": downloadUrl,
    });

    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();

      Route route =
          MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
      Navigator.pushReplacement(context, route);
    });
  }

  savePesoInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Peso')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "peso": double.parse(_textPeso.text) != null
          ? double.parse(_textPeso.text)
          : null,
      "fechaPeso": DateTime.parse(_datePeso.text),
    });
    setState(() {
      _textPeso.clear();
      _datePeso.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
  }

  saveTempInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Temperatura')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "temperatura": double.parse(_textTemp.text),
      "fechaTemperatura": DateTime.parse(_dateTemp.text),
    });
    setState(() {
      _textTemp.clear();
      _dateTemp.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
  }

  saveEsteInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Esterilizacion')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "esteril": _textEste.text.trim(),
      "fechaEsteril": DateTime.parse(_dateEste.text),
    });
    setState(() {
      _textEste.clear();
      _dateEste.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
  }

  saveAlergiaInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Alergias')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "alergia": _aler,
      "fechaAlergia": DateTime.parse(_dateAler.text),
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
    setState(() {
      _dateAler.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  savePatoInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Patologias')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "patologia": _pat,
      "fechaPatologia": DateTime.parse(_datePat.text),
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
    setState(() {
      _datePat.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  saveVacunaInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Vacunas')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "vacuna": _vacu,
      "fechaVacuna": DateTime.parse(_dateVacu.text),
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
    setState(() {
      _dateVacu.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  saveDespaInfo() {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference
        .collection('Expedientes')
        .doc(widget.petModel.mid)
        .collection('Desparasitacion')
        .doc(productId)
        .set({
      "mid": widget.petModel.mid,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
      "eid": productId,
      "fechaDesparasitacion": DateTime.parse(_dateDesparasitacion.text),
    });
    // setState(() {
    //   Route route =
    //       MaterialPageRoute(builder: (c) => HistoriaMedica(petModel: model));
    //   Navigator.pushReplacement(context, route);
    // });
    setState(() {
      _dateDesparasitacion.clear();
      productId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Widget _buildChart(BuildContext context, List<ExpedienteChart> expe) {
    mydata = expe;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 400.0,
        width: double.infinity,
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData,
                  animate: true,
                  animationDuration: Duration(seconds: 2),
                  barGroupingType: charts.BarGroupingType.groupedStacked,
                  defaultRenderer: new charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart2(
      BuildContext context, List<TemperaturaChart> temperaturachart) {
    mydata2 = temperaturachart;
    _generateData2(mydata2);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 400.0,
        width: double.infinity,
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData2,
                  animate: true,
                  animationDuration: Duration(seconds: 2),
                  barGroupingType: charts.BarGroupingType.groupedStacked,
                  defaultRenderer: new charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _selectDatePeso(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _datePeso.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateDesparasitacion(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateDesparasitacion.value =
            TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateTemp(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateTemp.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateEste(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateEste.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateVacu(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateVacu.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDateAler(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _dateAler.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  Future<Null> _selectDatePat(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        _datePat.value = TextEditingValue(text: timeString.split(" ")[0]);
      });
  }
}
