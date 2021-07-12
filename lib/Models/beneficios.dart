import 'package:cloud_firestore/cloud_firestore.dart';

class BeneficiosModel {
  String cantidad;
  String descripcion;
  Timestamp publishedDate;
  String disponible;
  String titulo;


  BeneficiosModel(
      {this.cantidad,
        this.descripcion,
        this.publishedDate,
        this.disponible,
        this.titulo,

        });

  BeneficiosModel.fromJson(Map<String, dynamic> json) {
    cantidad = json['cantidad'];
    descripcion = json['descripcion'];
    publishedDate = json['publishedDate'];
    disponible = json['disponible'];
    titulo = json['titulo'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cantidad'] = this.cantidad;
    data['descripcion'] = this.descripcion;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['disponible'] = this.disponible;
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
