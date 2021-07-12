import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoModel {
  String iId, aliadoId, productoId, uid, titulo, nombreComercial;
  dynamic cantidad, total, precio;
  Timestamp createdOn;

  CarritoModel({
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
  });

  Map<String, dynamic> toJson() => {
        'aliadoId': aliadoId,
        'productoId': productoId,
        'cantidad': cantidad,
        'precio': precio,
        'createdOn': createdOn,
        'total': total,
        'uid': uid,
        'iId': iId,
        'titulo': titulo,
        'nombreComercial': nombreComercial,
      };

  CarritoModel.fromSnapshot(DocumentSnapshot snapshot) {
    uid = snapshot['uid'];
    iId = snapshot['iId'];
    aliadoId = snapshot['aliadoId'];
    productoId = snapshot['productoId'];
    cantidad = snapshot['cantidad'];
    precio = snapshot['precio'];
    createdOn = snapshot['createdOn'];
    total = snapshot['total'];
    titulo = snapshot['titulo'];
    nombreComercial = snapshot['nombreComercial'];
  }
}
