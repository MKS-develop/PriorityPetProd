import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  String nombre;
  String shortInfo;
  Timestamp publishedDate;
  String petthumbnailUrl;
  String longDescription;
  String status;
  Timestamp fechanac;
  String especie;
  String raza;
  String sexo;
  String acerca;
  String mid;
  String uid, edadMascota, tamanoMascota, historia;
  int views;
  String aliadoId;

  PetModel({
    this.nombre,
    this.shortInfo,
    this.publishedDate,
    this.petthumbnailUrl,
    this.longDescription,
    this.status,
    this.fechanac,
    this.especie,
    this.raza,
    this.sexo,
    this.acerca,
    this.mid,
    this.uid,
    this.edadMascota,
    this.tamanoMascota,
    this.historia,
    this.views,
    this.aliadoId,
  });

  PetModel.fromJson(Map<String, dynamic> json) {
    nombre = json['nombre'];
    shortInfo = json['shortInfo'];
    publishedDate = json['publishedDate'];
    petthumbnailUrl = json['petthumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    fechanac = json['fechanac'];
    especie = json['especie'];
    raza = json['raza'];
    sexo = json['sexo'];
    acerca = json['acerca'];
    mid = json['mid'];
    uid = json['uid'];
    edadMascota = json['edadMascota'];
    tamanoMascota = json['tamanoMascota'];
    historia = json['historia'];
    views = json['views'];
    aliadoId = json['aliadoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['shortInfo'] = this.shortInfo;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['petthumbnailUrl'] = this.petthumbnailUrl;
    data['longDescription'] = this.longDescription;
    data['status'] = this.status;
    data['fechanac'] = this.fechanac;
    data['especie'] = this.especie;
    data['raza'] = this.raza;
    data['sexo'] = this.sexo;
    data['acerca'] = this.acerca;
    data['mid'] = this.mid;
    data['uid'] = this.uid;
    data['edadMascota'] = this.edadMascota;
    data['tamanoMascota'] = this.tamanoMascota;
    data['historia'] = this.historia;
    data['views'] = this.views;
    data['aliadoId'] = this.aliadoId;
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
