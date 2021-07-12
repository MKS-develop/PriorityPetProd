import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String titulo,
      aliadoId,
      productoId,
      categoria,
      mascota,
      dirigido,
      descripcion,
      urlImagen,
      tipoMascota,
      presentacion;
  int cantidad;
  dynamic precio, delivery;
  Timestamp createdOn;

  ProductModel({
    this.titulo,
    this.aliadoId,
    this.productoId,
    this.categoria,
    this.mascota,
    this.dirigido,
    this.descripcion,
    this.urlImagen,
    this.cantidad,
    this.delivery,
    this.precio,
    this.createdOn,
    this.tipoMascota,
    this.presentacion,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    titulo = json['titulo'];
    aliadoId = json['aliadoId'];
    productoId = json['productoId'];
    categoria = json['categoria'];
    mascota = json['mascota'];
    dirigido = json['dirigido'];
    descripcion = json['descripcion'];
    urlImagen = json['urlImagen'];
    cantidad = json['cantidad'];
    delivery = json['delivery'];
    precio = json['precio'];
    createdOn = json['createdOn'];
    tipoMascota = json['tipoMascota'];
    presentacion = json['presentacion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['titulo'] = this.titulo;
    data['aliadoId'] = this.aliadoId;
    data['productoId'] = this.productoId;
    data['categoria'] = this.categoria;
    data['mascota'] = this.mascota;
    data['dirigido'] = this.dirigido;
    data['descripcion'] = this.descripcion;
    data['urlImagen'] = this.urlImagen;
    data['cantidad'] = this.cantidad;
    data['delivery'] = this.delivery;
    data['precio'] = this.precio;
    data['createdOn'] = this.createdOn;
    data['tipoMascota'] = this.tipoMascota;
    data['presentacion'] = this.presentacion;
    return data;
  }
}
