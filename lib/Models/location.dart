import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel{
  String aliadoId;
  String localidadId;
  String locacionImg;
  String nombreLocalidad;
  String direccionLocalidad;
  String direccionDetallada;
  String ciudad;
  List<dynamic> telefonos;
  Timestamp createdOn;
  GeoPoint location;
  String mapAddress;

  LocationModel({
    this.aliadoId,
    this.localidadId,
    this.locacionImg,
    this.nombreLocalidad,
    this.direccionLocalidad,
    this.direccionDetallada,
    this.ciudad,
    this.telefonos,
    this.createdOn,
    this.location,
    this.mapAddress,
  });

  LocationModel.fromJson(Map<String, dynamic> json){
    aliadoId = json['aliadoId'];
    localidadId = json['localidadId'];
    locacionImg = json['locacionImg'];
    nombreLocalidad = json['nombreLocalidad'];
    direccionLocalidad = json['direccionLocalidad'];
    direccionDetallada = json['direccionDetallada'];
    ciudad = json['ciudad'];
    telefonos = json['telefonos'];
    createdOn = json['createdOn'];
    location = json['location'];
    mapAddress = json['mapAddress'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['aliadoId'] = this.aliadoId;
    data['localidadId'] = this.localidadId;
    data['locacionImg'] = this.locacionImg;
    data['nombreLocalidad'] = this.nombreLocalidad;
    data['direccionLocalidad'] = this.direccionLocalidad;
    data['direccionDetallada'] = this.direccionDetallada;
    data['ciudad'] = this.ciudad;
    data['telefonos'] = this.telefonos;
    data['createdOn'] = this.createdOn;
    data['location'] = this.location;
    data['mapAddress'] = this.mapAddress;

    return data;
  }
}