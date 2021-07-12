import 'package:cloud_firestore/cloud_firestore.dart';

class ServModel {
  String titulo,
      aliadoId,
      servicioId,
      categoria,
      descripcion,
      condiciones,
      urlImagen;
  dynamic capacidad, delivery, precio, domicilio;
  Timestamp createdOn;
  bool activo;

  ServModel({
    this.titulo,
    this.aliadoId,
    this.servicioId,
    this.categoria,
    this.descripcion,
    this.condiciones,
    this.urlImagen,
    this.capacidad,
    this.precio,
    this.delivery,
    this.domicilio,
    this.activo,
    this.createdOn,
  });

  ServModel.fromJson(Map<String, dynamic> json) {
    titulo = json['titulo'];
    aliadoId = json['aliadoId'];
    servicioId = json['servicioId'];
    categoria = json['categoria'];
    descripcion = json['descripcion'];
    condiciones = json['condiciones'];
    urlImagen = json['urlImagen'];
    capacidad = json['capacidad'];
    precio = json['precio'];
    delivery = json['delivery'];
    domicilio = json['domicilio'];
    activo = json['activo'];
    createdOn = json['createdOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['titulo'] = this.titulo;
    data['aliadoId'] = this.aliadoId;
    data['servicioId'] = this.servicioId;
    data['categoria'] = this.categoria;
    data['descripcion'] = this.descripcion;
    data['condiciones'] = this.condiciones;
    data['urlImagen'] = this.urlImagen;
    data['capacidad'] = this.capacidad;
    data['precio'] = this.precio;
    data['delivery'] = this.delivery;
    data['domicilio'] = this.domicilio;
    data['activo'] = this.activo;
    data['createdOn'] = this.createdOn;

    return data;
  }
}
