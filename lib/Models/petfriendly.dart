import 'package:cloud_firestore/cloud_firestore.dart';

class PetFriendlyModel {
  String aliadoId;
  String nombre;
  Timestamp publishedDate;
  String pais;
  String telefono;
  String avatar;
  String email;
  String direccion;


  PetFriendlyModel(
      {this.nombre,
        this.aliadoId,
        this.publishedDate,
        this.pais,
        this.telefono,
        this.avatar,
        this.email,
        this.direccion,

        });

  PetFriendlyModel.fromJson(Map<String, dynamic> json) {
    nombre = json['nombre'];
    aliadoId = json['aliadoId'];
    publishedDate = json['publishedDate'];
    pais = json['pais'];
    telefono = json['telefono'];
    avatar = json['avatar'];
    email = json['email'];
    direccion = json['direccion'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['aliadoId'] = this.aliadoId;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['pais'] = this.pais;
    data['telefono'] = this.telefono;
    data['avatar'] = this.avatar;
    data['email'] = this.email;
    data['direccion'] = this.direccion;


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
