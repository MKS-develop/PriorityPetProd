import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
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

  Producto({
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

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'aliadoId': aliadoId,
        'productoId': productoId,
        'categoria': categoria,
        'mascota': mascota,
        'dirigido': dirigido,
        'descripcion': descripcion,
        'urlImagen': urlImagen,
        'cantidad': cantidad,
        'delivery': delivery,
        'precio': precio,
        'createdOn': createdOn,
        'tipoMascota': tipoMascota,
        'presentacion': presentacion,
      };

  Producto.fromSnapshot(DocumentSnapshot snapshot) {
    titulo = snapshot['titulo'];
    aliadoId = snapshot['aliadoId'];
    productoId = snapshot['productoId'];
    categoria = snapshot['categoria'];
    mascota = snapshot['mascota'];
    dirigido = snapshot['dirigido'];
    descripcion = snapshot['descripcion'];
    urlImagen = snapshot['urlImagen'];
    cantidad = snapshot['cantidad'];
    delivery = snapshot['delivery'];
    precio = snapshot['precio'];
    createdOn = snapshot['createdOn'];
    tipoMascota = snapshot['tipoMascota'];
    presentacion = snapshot['presentacion'];
  }
}
