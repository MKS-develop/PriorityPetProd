import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicasModel {
  String nombre,
      nombreComercial,
      aliadoId,
      productoId,
      categoria,
      tipoAliado,
      direccion,
      descripcion,
      avatar,
      ciudad,
      horario,
      pais,
      locacion,
      telefono;
  dynamic cantidad, delivery, precio;
  Timestamp createdOn;

  ClinicasModel(
      {this.nombre,
      this.nombreComercial,
      this.aliadoId,
      this.productoId,
      this.categoria,
      this.tipoAliado,
      this.direccion,
      this.descripcion,
      this.avatar,
      this.cantidad,
      this.delivery,
      this.precio,
      this.createdOn,
      this.ciudad,
      this.horario,
      this.pais,
      this.locacion,
      this.telefono});

  factory ClinicasModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ClinicasModel(
      nombre: data['nombre'],
      nombreComercial: data['nombreComercial'],
      aliadoId: data['aliadoId'],
      productoId: data['productoId'],
      categoria: data['categoria'],
      tipoAliado: data['tipoAliado'],
      direccion: data['direccion'],
      descripcion: data['descripcion'],
      avatar: data['avatar'],
      cantidad: data['cantidad'],
      delivery: data['delivery'],
      precio: data['precio'],
      createdOn: data['createdOn'],
      ciudad: data['ciudad'],
      horario: data['horario'],
      pais: data['pais'],
      locacion: data['locacion'],
      telefono: data['telefono'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'nombreComercial': nombreComercial,
        'aliadoId': aliadoId,
        'productoId': productoId,
        'categoria': categoria,
        'tipoAliado': tipoAliado,
        'direccion': direccion,
        'descripcion': descripcion,
        'avatar': avatar,
        'cantidad': cantidad,
        'delivery': delivery,
        'precio': precio,
        'createdOn': createdOn,
        'ciudad': ciudad,
        'horario': horario,
        'pais': pais,
        'locacion': locacion,
        'telefono': telefono,
      };

  ClinicasModel.fromSnapshot(DocumentSnapshot snapshot) {
    nombre = snapshot['nombre'];
    nombreComercial = snapshot['nombreComercial'];
    aliadoId = snapshot['aliadoId'];
    productoId = snapshot['productoId'];
    categoria = snapshot['categoria'];
    tipoAliado = snapshot['tipoAliado'];
    direccion = snapshot['direccion'];
    descripcion = snapshot['descripcion'];
    avatar = snapshot['avatar'];
    cantidad = snapshot['cantidad'];
    delivery = snapshot['delivery'];
    precio = snapshot['precio'];
    createdOn = snapshot['createdOn'];
    ciudad = snapshot['ciudad'];
    horario = snapshot['horario'];
    pais = snapshot['pais'];
    locacion = snapshot['locacion'];
    telefono = snapshot['telefono'];
  }
}
