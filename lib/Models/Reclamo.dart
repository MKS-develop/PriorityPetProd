import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamoModel{
  String id;
  String reclamoId;
  String codigoAliado;
  String reclamo;
  String numeroOrden;
  String tipoReclamo;
  String razonReclamo;
  String descripcion;
  String accion;
  String status;
  String usuarioAtendio;
  Timestamp fechaReclamo;
  Timestamp fechaCierre;

  ReclamoModel({
    this.id,
    this.reclamoId,
    this.codigoAliado,
    this.reclamo,
    this.numeroOrden,
    this.tipoReclamo,
    this.razonReclamo,
    this.descripcion,
    this.accion,
    this.status,
    this.usuarioAtendio,
    this.fechaReclamo,
    this.fechaCierre,
    
  });

  ReclamoModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    reclamoId = json['reclamoId'];
    codigoAliado = json['codigoAliado'];
    reclamo = json['reclamo'];
    numeroOrden = json['numeroOrden'];
    tipoReclamo = json['tipoReclamo'];
    razonReclamo = json['razonReclamo'];
    descripcion = json['descripcion'];
    accion = json['accion'];
    status = json['status'];
    usuarioAtendio = json['usuarioAtendio'];
    fechaReclamo = json['fechaReclamo'];
    fechaCierre = json['fechaCierre'];
    
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['reclamoId'] = this.reclamoId;
    data['codigoAliado'] = this.codigoAliado;
    data['reclamo'] = this.reclamo;
    data['numeroOrden'] = this.numeroOrden;
    data['tipoReclamo'] = this.tipoReclamo;
    data['razonReclamo'] = this.razonReclamo;
    data['descripcion'] = this.descripcion;
    data['accion'] = this.accion;
    data['status'] = this.status;
    data['usuarioAtendio'] = this.usuarioAtendio;
    data['fechaReclamo'] = this.fechaReclamo;
    data['fechaCierre'] = this.fechaCierre;

    return data;
  }
}