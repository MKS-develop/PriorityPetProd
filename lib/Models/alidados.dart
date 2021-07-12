import 'package:cloud_firestore/cloud_firestore.dart';

class AliadoModel {
  String aliadoId;
  String avatar;
  String password;
  String email;
  String pais;
  String telefono;
  String locacion;
  String nombre;
  String tipoEmpresa;
  String nombreComercial;
  String identificacion;
  String tipoAliado;
  String geolocation;
  String direccion;
  dynamic totalRatings, countRatings, sumaTotal, delivery;

 AliadoModel(
      {    this.aliadoId,
        this.avatar,
        this.password,
        this.email,
        this.pais,
        this.telefono,
        this.locacion,
        this.nombre,
        this.tipoEmpresa,
        this.nombreComercial,
        this.identificacion,
        this.tipoAliado,
        this.geolocation,
        this.totalRatings,
        this.countRatings,
        this.direccion,
        this.sumaTotal,
        this.delivery,


      });

  AliadoModel.fromJson(Map<String, dynamic> json) {
    aliadoId = json['aliadoId'];
    avatar = json['avatar'];
    password = json['password'];
    email = json['email'];
    pais = json['pais'];
    telefono = json['telefono'];
    locacion = json['locacion'];
    nombre = json['nombre'];
    tipoEmpresa = json['tipoEmpresa'];
    nombreComercial = json['nombreComercial'];
    identificacion = json['identificacion'];
    tipoAliado = json['tipoAliado'];
    geolocation = json['geolocation'];
    totalRatings = json['totalRatings'];
    countRatings = json['countRatings'];
    direccion = json['direccion'];
    sumaTotal = json['sumaTotal'];
    delivery = json['delivery'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aliadoId'] = this.aliadoId;
    data['avatar'] = this.avatar;
    data['password'] = this.password;
    data['email'] = this.email;
    data['pais'] = this.pais;
    data['telefono'] = this.telefono;
    data['locacion'] = this.locacion;
    data['nombre'] = this.nombre;
    data['tipoEmpresa'] = this.tipoEmpresa;
    data['nombreComercial'] = this.nombreComercial;
    data['identificacion'] = this.identificacion;
    data['tipoAliado'] = this.tipoAliado;
    data['geolocation'] = this.geolocation;
    data['totalRatings'] = this.totalRatings;
    data['countRatings'] = this.countRatings;
    data['direccion'] = this.direccion;
    data['sumaTotal'] = this.sumaTotal;
    data['delivery'] = this.delivery;

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
