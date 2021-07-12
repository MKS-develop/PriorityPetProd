import 'package:cloud_firestore/cloud_firestore.dart';

class ComentariosModel{
  String descripcion;
  String comentarioId;
  Timestamp createdOn;
  String urlImagen;
  String uid;
  int likes;
  String aliadoId;
  String usuarioNombre;

  ComentariosModel({
    this.descripcion,
    this.createdOn,
    this.urlImagen,
    this.uid,
    this.likes,
    this.comentarioId,
    this.aliadoId,
    this.usuarioNombre,
  });

  ComentariosModel.fromJson(Map<String, dynamic> json){
    descripcion = json['descripcion'];
    createdOn = json['createdOn'];
    urlImagen = json['urlImagen'];
    uid = json['uid'];
    likes = json['likes'];
    comentarioId = json['postId'];
    aliadoId = json['aliadoId'];
    usuarioNombre = json['usuarioNombre'];

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['descripcion'] = this.descripcion;
    data['createdOn'] = this.createdOn;
    data['urlImagen'] = this.urlImagen;
    data['uid'] = this.uid;
    data['likes'] = this.likes;
    data['comentarioId'] = this.comentarioId;
    data['aliadoId'] = this.aliadoId;
    data['usuarioNombre'] = this.usuarioNombre;

    return data;
  }
}