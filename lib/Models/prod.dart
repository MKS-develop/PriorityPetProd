import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoModel {
  String titulo,
      aliadoId,
      productoId,
      categoria,
      mascota,
      dirigido,
      descripcion,
      urlImagen,
      tipoMascota,
      presentacion,
  localidadId,
  pesoValor,
  pesoUnidad;
  dynamic cantidad;
  dynamic precio, delivery;
  Timestamp createdOn;


  ProductoModel({
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
    this.pesoUnidad,
    this.pesoValor,
    this.localidadId,
  });

  factory ProductoModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ProductoModel(
      titulo: data['titulo'],
      aliadoId: data['aliadoId'],
      productoId: data['productoId'],
      categoria: data['categoria'],
      mascota: data['mascota'],
      dirigido: data['dirigido'],
      urlImagen: data['urlImagen'],
      precio: data['precio'],
      delivery: data['delivery'],
      descripcion: data['descripcion'],
      cantidad: data['cantidad'],
      createdOn: data['createdOn'],
      tipoMascota: data['tipoMascota'],
      presentacion: data['presentacion'],
      pesoUnidad: data['pesoUnidad'],
      pesoValor: data['pesoValor'],
      localidadId: data['localidadId'],
    );
  }

  ProductoModel.fromSnapshot(DocumentSnapshot snapshot) {
    titulo = snapshot['titulo'];
    aliadoId = snapshot['aliadoId'];
    productoId = snapshot['productoId'];
    categoria = snapshot['categoria'];
    descripcion = snapshot['descripcion'];
    mascota = snapshot['mascota'];
    urlImagen = snapshot['urlImagen'];
    precio = snapshot['precio'];
    delivery = snapshot['delivery'];
    createdOn = snapshot['createdOn'];
    tipoMascota = snapshot['tipoMascota'];
    presentacion = snapshot['presentacion'];
    dirigido = snapshot['dirigido'];
    cantidad = snapshot['cantidad'];
    pesoValor = snapshot['pesoValor'];
    pesoUnidad = snapshot['pesoUnidad'];
    localidadId = snapshot['localidadId'];
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'aliadoId': aliadoId,
        'productoId': productoId,
        'categoria': categoria,
        'descripcion': descripcion,
        'urlImagen': urlImagen,
        'precio': precio,
        'delivery': delivery,
        'createdOn': createdOn,
        'cantidad': cantidad,
        'dirigido': dirigido,
        'presentacion': presentacion,
        'tipoMascota': tipoMascota,
        'mascota': mascota,
    'pesoValor': pesoValor,
    'pesoUnidad': pesoUnidad,
      };
}
