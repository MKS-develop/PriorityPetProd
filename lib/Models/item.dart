import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String iId,
      aliadoId,
      productoId,
      uid,
      titulo,
      nombreComercial,
      fecha,
      hora,
      petthumbnailUrl,
      servicioid,
      promoid;
  dynamic cantidad, total, precio, delivery, domicilio;
  Timestamp createdOn;
  bool tieneDelivery, tieneDomicilio;

  ItemModel({
    this.uid,
    this.iId,
    this.aliadoId,
    this.productoId,
    this.cantidad,
    this.precio,
    this.createdOn,
    this.total,
    this.titulo,
    this.nombreComercial,
    this.fecha,
    this.hora,
    this.petthumbnailUrl,
    this.promoid,
    this.servicioid,
    this.tieneDelivery,
    this.delivery,
    this.tieneDomicilio,
    this.domicilio,
  });

  ItemModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    iId = json['iId'];
    aliadoId = json['aliadoId'];
    productoId = json['productoId'];
    cantidad = json['cantidad'];
    precio = json['precio'];
    createdOn = json['createdOn'];
    total = json['total'];
    titulo = json['titulo'];
    nombreComercial = json['nombreComercial'];
    fecha = json['fecha'];
    hora = json['hora'];
    petthumbnailUrl = json['petthumbnailUrl'];
    servicioid = json['servicioid'];
    promoid = json['promoid'];
    tieneDelivery = json['tieneDelivery'];
    delivery = json['delivery'];
    tieneDomicilio = json['tieneDomicilio'];
    domicilio = json['domicilio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['iId'] = this.iId;
    data['aliadoId'] = this.aliadoId;
    data['productoId'] = this.productoId;
    data['total'] = this.total;
    data['cantidad'] = this.cantidad;
    data['precio'] = this.precio;
    data['createdOn'] = this.createdOn;
    data['titulo'] = this.titulo;
    data['nombreComercial'] = this.nombreComercial;
    data['fecha'] = this.fecha;
    data['hora'] = this.hora;
    data['petthumbnailUrl'] = this.petthumbnailUrl;
    data['servicioid'] = this.servicioid;
    data['promoid'] = this.promoid;
    data['tieneDelivery'] = this.tieneDelivery;
    data['delivery'] = this.delivery;
    data['tieneDomicilio'] = this.tieneDomicilio;
    data['domicilio'] = this.domicilio;
    return data;
  }
}
