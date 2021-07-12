import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String titulo,
      aliadoId,
      servicioId,
      categoria,
      descripcion,
      condiciones,
      urlImagen,
      ciudad,
      direccion,
      localidadId,
      tipoAgenda;
  dynamic capacidad, delivery, precio, domicilio, totalRatings, countRatings;
  Timestamp createdOn, date;
  bool activo;

  ServiceModel({
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
    this.localidadId,
    this.tipoAgenda,
    this.date,
  });

  factory ServiceModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ServiceModel(
      titulo: data['titulo'],
      aliadoId: data['aliadoId'],
      servicioId: data['servicioId'],
      categoria: data['categoria'],
      descripcion: data['descripcion'],
      condiciones: data['condiciones'],
      urlImagen: data['urlImagen'],
      precio: data['precio'],
      delivery: data['delivery'],
      domicilio: data['domicilio'],
      activo: data['activo'],
      createdOn: data['createdOn'],
      ciudad: data['ciudad'],
      direccion: data['direccion'],
      countRatings: data['countRatings'],
      totalRatings: data['totalRatings'],
      localidadId: data['localidadId'],
      tipoAgenda: data['tipoAgenda'],
      date: data['date'],
    );
  }

  ServiceModel.fromSnapshot(DocumentSnapshot snapshot) {
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
    tipoAgenda = snapshot['tipoAgenda'];
    date = snapshot['date'];
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
        'tipoAgenda': tipoAgenda,
        'date': tipoAgenda,
      };
}
