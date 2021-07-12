import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritosModel{
  String uid;
  bool like;

  FavoritosModel({
    this.uid,
    this.like,

  });

  FavoritosModel.fromJson(Map<String, dynamic> json){
    uid = json['uid'];
    like = json['like'];

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['like'] = this.like;


    return data;
  }
}