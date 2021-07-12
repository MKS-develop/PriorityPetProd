import 'package:cloud_firestore/cloud_firestore.dart';

class ExpedienteChart {
  dynamic peso;
  // int temperatura;
  Timestamp fechaPeso;
  // Timestamp fechaTemperatura;

  ExpedienteChart(
    this.peso,
    // this.temperatura,
    this.fechaPeso,
    // this.fechaTemperatura,
  );

  ExpedienteChart.fromMap(Map<String, dynamic> map)
      : assert(map['peso'] != null),
        // assert(map['temperatura'] != null),
        assert(map['fechaPeso'] != null),
        // assert(map['fechaTemperatura'] != null),
        peso = map['peso'],
        // temperatura = map['temperatura'],
        fechaPeso = map['fechaPeso'];
  // fechaTemperatura=map['fechaTemperatura'];

  @override
  String toString() => "Record<$peso$fechaPeso>";
}
