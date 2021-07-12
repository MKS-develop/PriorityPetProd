import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  String titulo,
      aliadoid,
      promoid,
      categoria,
      descripcion,
      condiciones,
      urlImagen,
      fecha,
      tipoPromocion,
      tipoAgenda;
  dynamic capacidad, delivery, precio, domicilio;
  Timestamp createdOn, date;
  bool activo;

  PromotionModel({
    this.titulo,
    this.aliadoid,
    this.promoid,
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
    this.fecha,
    this.tipoPromocion,
    this.tipoAgenda,
    this.date,
  });

  PromotionModel.fromJson(Map<String, dynamic> json) {
    titulo = json['titulo'];
    aliadoid = json['aliadoId'];
    promoid = json['promoId'];
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
    fecha = json['fecha'];
    tipoPromocion = json['tipoPromocion'];
    tipoAgenda = json['tipoAgenda'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['titulo'] = this.titulo;
    data['aliadoId'] = this.aliadoid;
    data['promoId'] = this.promoid;
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
    data['fecha'] = this.fecha;
    data['tipoPromocion'] = this.tipoPromocion;
    data['tipoAgenda'] = this.tipoAgenda;
    data['date'] = this.date;

    return data;
  }
}
