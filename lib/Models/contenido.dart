import 'package:cloud_firestore/cloud_firestore.dart';

class ContenidoModel{
  String descripcion;
  String postId;
  Timestamp createdOn;
  String urlImagen;
  String titulo;
  int likes;
  String aliadoId;

  ContenidoModel({
    this.descripcion,
    this.createdOn,
    this.urlImagen,
    this.titulo,
    this.likes,
    this.postId,
    this.aliadoId
  });

  factory ContenidoModel.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ContenidoModel(
      titulo: data['titulo'],
      aliadoId: data['aliadoId'],
      descripcion: data['descripcion'],
      urlImagen: data['urlImagen'],
      likes: data['likes'],
      postId: data['postId'],

      createdOn: data['createdOn'],

    );
  }

  ContenidoModel.fromJson(Map<String, dynamic> json){
    descripcion = json['descripcion'];
    createdOn = json['createdOn'];
    urlImagen = json['urlImagen'];
    titulo = json['titulo'];
    likes = json['likes'];
    postId = json['postId'];
    aliadoId = json['aliadoId'];

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['descripcion'] = this.descripcion;
    data['createdOn'] = this.createdOn;
    data['urlImagen'] = this.urlImagen;
    data['titulo'] = this.titulo;
    data['likes'] = this.likes;
    data['postId'] = this.postId;
    data['aliadoId'] = this.aliadoId;

    return data;
  }
}