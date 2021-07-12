import 'package:cloud_firestore/cloud_firestore.dart';

class ExpedienteModel {
  dynamic peso;
  dynamic temperatura;
  Timestamp publishedDate;
  String historiathumbnailUrl;
  String vacuna;
  String alergia;
  String patologia;
  String esteril;

  Timestamp fechaPeso;
  Timestamp fechaAlergia;
  Timestamp fechaPatologia;

  Timestamp fechaEsteril;
  Timestamp fechaDesparasitacion;
  Timestamp fechaTemperatura;
  Timestamp fechaVacuna;
  String eid;
  String uid;
  String mid;
  String titulo;

  ExpedienteModel({
    this.peso,
    this.temperatura,
    this.publishedDate,
    this.historiathumbnailUrl,
    this.vacuna,
    this.alergia,
    this.patologia,
    this.esteril,
    this.fechaPeso,
    this.fechaAlergia,
    this.fechaPatologia,
    this.fechaEsteril,
    this.fechaDesparasitacion,
    this.fechaTemperatura,
    this.fechaVacuna,
    this.eid,
    this.uid,
    this.mid,
    this.titulo,
  });

  ExpedienteModel.fromJson(Map<String, dynamic> json) {
    peso = json['peso'];
    temperatura = json['temperatura'];
    publishedDate = json['publishedDate'];
    historiathumbnailUrl = json['historiathumbnailUrl'];
    vacuna = json['vacuna'];
    alergia = json['alergia'];
    patologia = json['patologia'];
    esteril = json['esteril'];
    fechaPeso = json['fechaPeso'];
    fechaAlergia = json['fechaAlergia'];
    fechaPatologia = json['fechaPatologia'];
    fechaEsteril = json['fechaEsteril'];
    fechaDesparasitacion = json['fechaDesparasitacion'];
    fechaTemperatura = json['fechaTemperatura'];
    fechaVacuna = json['fechaVacuna'];
    eid = json['eid'];
    mid = json['mid'];
    uid = json['uid'];
    titulo = json['titulo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['peso'] = this.peso;
    data['temperatura'] = this.temperatura;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['historiathumbnailUrl'] = this.historiathumbnailUrl;
    data['vacuna'] = this.vacuna;
    data['alergia'] = this.alergia;
    data['patologia'] = this.patologia;
    data['esteril'] = this.esteril;
    data['fechaPeso'] = this.fechaPeso;
    data['fechaAlergia'] = this.fechaAlergia;
    data['fechaPatologia'] = this.fechaPatologia;
    data['fechaEsteril'] = this.fechaEsteril;
    data['fechaDesparasitacion'] = this.fechaDesparasitacion;
    data['fechaTemperatura'] = this.fechaTemperatura;
    data['fechaVacuna'] = this.fechaVacuna;
    data['eid'] = this.eid;
    data['mid'] = this.mid;
    data['uid'] = this.uid;
    data['titulo'] = this.titulo;

    return data;
  }
}

class PublishedDate {
  String date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
