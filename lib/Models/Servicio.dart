import 'package:cloud_firestore/cloud_firestore.dart';

class ServicioModel {
  String titulo,
      aliadoId,
      servicioId,
      categoria,
      descripcion,
      condiciones,
      urlImagen,
      ciudad,
      direccion;
  dynamic capacidad, delivery, precio, domicilio, totalRatings, countRatings;
  Timestamp createdOn;
  bool activo;

  ServicioModel({
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
    this.ciudad,
    this.direccion,
    this.countRatings,
    this.totalRatings,
  });

  ServicioModel.fromSnapshot(DocumentSnapshot snapshot) {
    titulo = snapshot['titulo'];
    aliadoId = snapshot['aliadoId'];
    servicioId = snapshot['servicioId'];
    categoria = snapshot['categoria'];
    descripcion = snapshot['descripcion'];
    condiciones = snapshot['condiciones'];
    urlImagen = snapshot['urlImagen'];
    capacidad = snapshot['capacidad'];
    precio = snapshot['precio'];
    delivery = snapshot['delivery'];
    domicilio = snapshot['domicilio'];
    activo = snapshot['activo'];
    createdOn = snapshot['createdOn'];
    ciudad = snapshot['ciudad'];
    direccion = snapshot['direccion'];
    countRatings = snapshot['countRatings'];
    totalRatings = snapshot['totalRatings'];
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'aliadoId': aliadoId,
        'servicioId': servicioId,
        'categoria': categoria,
        'descripcion': descripcion,
        'condiciones': condiciones,
        'urlImagen': urlImagen,
        'capacidad': capacidad,
        'precio': precio,
        'delivery': delivery,
        'domicilio': domicilio,
        'activo': activo,
        'createdOn': createdOn,
        'ciudad': ciudad,
        'direccion': direccion,
        'countRatings': countRatings,
        'totalRatings': totalRatings,
      };
}
