import 'package:cloud_firestore/cloud_firestore.dart';

class TemperaturaChart {
  dynamic temperatura;

  Timestamp fechaTemperatura;

  TemperaturaChart(
    this.temperatura,
    this.fechaTemperatura,
  );

  TemperaturaChart.fromMap(Map<String, dynamic> map)
      : assert(map['temperatura'] != null),
        assert(map['fechaTemperatura'] != null),
        temperatura = map['temperatura'],
        fechaTemperatura = map['fechaTemperatura'];

  @override
  String toString() => "Record<$temperatura$fechaTemperatura>";
}
