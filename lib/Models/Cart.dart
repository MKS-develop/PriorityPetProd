import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  String iId, aliadoId, productoId, uid, titulo, nombreComercial;
  dynamic cantidad, total, precio, sumaTotal;
  Timestamp createdOn;

  CartModel({
    this.uid,
    this.iId,
    this.aliadoId,
    this.productoId,
    this.cantidad,
    this.precio,
    this.createdOn,
    this.total,
    this.titulo,
    this.sumaTotal,
    this.nombreComercial,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    iId = json['iId'];
    aliadoId = json['aliadoId'];
    productoId = json['productoId'];
    cantidad = json['cantidad'];
    precio = json['precio'];
    createdOn = json['createdOn'];
    total = json['total'];
    titulo = json['titulo'];
    sumaTotal = json['sumaTotal'];
    nombreComercial = json['nombreComercial'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['iId'] = this.iId;
    data['aliadoId'] = this.aliadoId;
    data['productoId'] = this.productoId;
    data['total'] = this.total;
    data['cantidad'] = this.cantidad;
    data['precio'] = this.precio;
    data['createdOn'] = this.createdOn;
    data['titulo'] = this.titulo;
    data['sumaTotal'] = this.sumaTotal;
    data['nombreComercial'] = this.nombreComercial;

    return data;
  }
}
