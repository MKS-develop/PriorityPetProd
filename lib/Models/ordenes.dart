import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String oid,
      aliadoId,
      productoId,
      uid,
      promoid,
      titulo,
      mid,
      status,
      hora,
      fecha,
      tipoOrden,
      serviceid,
      statusCita,
      tipoPlan,
      localidadId,
      nombreComercial,
      videoId,
      petthumbnailUrl;
  dynamic cantidad, total, precio, ppGeneradosD, sumaTotal, delivery, montoAprobado;
  bool tieneDelivery, calificacion;

  Timestamp createdOn, date;

  OrderModel({
    this.petthumbnailUrl,
    this.uid,
    this.mid,
    this.oid,
    this.aliadoId,
    this.productoId,
    this.cantidad,
    this.precio,
    this.createdOn,
    this.total,
    this.promoid,
    this.titulo,
    this.status,
    this.hora,
    this.fecha,
    this.tipoOrden,
    this.serviceid,
    this.statusCita,
    this.ppGeneradosD,
    this.sumaTotal,
    this.tieneDelivery,
    this.delivery,
    this.calificacion,
    this.tipoPlan,
    this.localidadId,
    this.date,
    this.nombreComercial,
    this.videoId,
    this.montoAprobado
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    uid = json['uid'];
    oid = json['oid'];
    aliadoId = json['aliadoId'];
    productoId = json['productoId'];
    cantidad = json['cantidad'];
    precio = json['precio'];
    createdOn = json['createdOn'];
    total = json['total'];
    promoid = json['promoid'];
    titulo = json['titulo'];
    status = json['status'];
    fecha = json['fecha'];
    hora = json['hora'];
    tipoOrden = json['tipoOrden'];
    serviceid = json['serviceid'];
    statusCita = json['statusCita'];
    ppGeneradosD = json['ppGeneradosD'];
    sumaTotal = json['sumaTotal'];
    tieneDelivery = json['tieneDelivery'];
    delivery = json['delivery'];
    calificacion = json['calificacion'];
    tipoPlan = json['tipoPlan'];
    localidadId = json['localidadId'];
    date = json['date'];
    nombreComercial = json['nombreComercial'];
    petthumbnailUrl = json['petthumbnailUrl'];
    videoId = json['videoId'];
    montoAprobado = json['montoAprobado'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['mid'] = this.uid;
    data['uid'] = this.uid;
    data['oid'] = this.oid;
    data['aliadoId'] = this.aliadoId;
    data['productoId'] = this.productoId;
    data['total'] = this.total;
    data['cantidad'] = this.cantidad;
    data['precio'] = this.precio;
    data['createdOn'] = this.createdOn;
    data['promoid'] = this.promoid;
    data['titulo'] = this.titulo;
    data['status'] = this.status;
    data['fecha'] = this.fecha;
    data['hora'] = this.hora;
    data['tipoOrden'] = this.tipoOrden;
    data['serviceid'] = this.serviceid;
    data['statusCita'] = this.statusCita;
    data['ppGeneradosD'] = this.ppGeneradosD;
    data['sumaTotal'] = this.sumaTotal;
    data['tieneDelivery'] = this.tieneDelivery;
    data['delivery'] = this.delivery;
    data['calificacion'] = this.calificacion;
    data['tipoPlan'] = this.tipoPlan;
    data['localidadId'] = this.localidadId;
    data['date'] = this.date;
    data['nombreComercial'] = this.nombreComercial;
    data['videoId'] = this.videoId;
    data['montoAprobado'] = this.montoAprobado;
    return data;
  }
}
